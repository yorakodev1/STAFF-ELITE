<?php
/**
 * Proxy Seguro para Google Gemini API
 * Previene exposición de API keys en el frontend
 * 
 * Requiere: Configuración de GEMINI_API_KEY en .env o variables de servidor
 */

// ============= CONFIGURACIÓN =============
define('MAX_REQUESTS_PER_HOUR', 20);
define('LOG_DIR', dirname(__DIR__) . '/logs');

// ============= HEADERS DE SEGURIDAD =============
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Referrer-Policy: strict-origin-only');

// CORS - Permitir solo tu dominio en producción
$allowed_origins = [
    'http://localhost',
    'http://localhost:3000',
    'http://localhost:8000',
    'http://127.0.0.1',
    'https://staffeliteperu.com',
    'https://www.staffeliteperu.com'
];

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';

if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: {$origin}");
    header("Access-Control-Allow-Methods: POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, X-Requested-With");
}

// Manejar requests OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ============= VALIDACIÓN DE REQUEST =============

// Solo permitir POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido. Solo POST es aceptado.']);
    exit;
}

// Validar Content-Type
$content_type = isset($_SERVER['CONTENT_TYPE']) ? $_SERVER['CONTENT_TYPE'] : '';
if (strpos($content_type, 'application/json') === false) {
    http_response_code(400);
    echo json_encode(['error' => 'Content-Type debe ser application/json']);
    exit;
}

// ============= RATE LIMITING =============

function checkRateLimit($identifier) {
    $cache_key = 'gemini_api_' . hash('sha256', $identifier);
    $cache_file = sys_get_temp_dir() . '/' . $cache_key . '.tmp';
    
    $current_hour = date('Y-m-d H:00:00');
    $hour_key = 'hour_' . strtotime($current_hour);
    
    if (file_exists($cache_file)) {
        $data = json_decode(file_get_contents($cache_file), true);
        
        // Si cambió la hora, resetear contador
        if ($data['hour'] !== $hour_key) {
            $data = ['count' => 1, 'hour' => $hour_key];
        } else {
            $data['count']++;
        }
    } else {
        $data = ['count' => 1, 'hour' => $hour_key];
    }
    
    file_put_contents($cache_file, json_encode($data));
    
    return $data['count'] <= MAX_REQUESTS_PER_HOUR;
}

$client_ip = $_SERVER['REMOTE_ADDR'];
if (!checkRateLimit($client_ip)) {
    http_response_code(429);
    echo json_encode(['error' => 'Límite de requests excedido. Máximo ' . MAX_REQUESTS_PER_HOUR . ' por hora.']);
    logRequest($client_ip, false, 'Rate limit exceeded');
    exit;
}

// ============= OBTENER API KEY =============

// Intentar obtener desde variables de servidor (cPanel/Plesk)
$api_key = getenv('GEMINI_API_KEY');

// Fallback: intentar desde archivo .env
if (!$api_key && file_exists(dirname(__DIR__) . '/.env')) {
    $env_content = file_get_contents(dirname(__DIR__) . '/.env');
    if (preg_match('/GEMINI_API_KEY\s*=\s*(.+)/', $env_content, $matches)) {
        $api_key = trim($matches[1], ' \'"');
    }
}

// Si no hay API key, retornar error
if (!$api_key || empty($api_key)) {
    http_response_code(500);
    echo json_encode(['error' => 'API key de Gemini no configurada en el servidor.']);
    logRequest($client_ip, false, 'Missing API key');
    exit;
}

// ============= PROCESAR REQUEST =============

$input = json_decode(file_get_contents('php://input'), true);

// Validar que tenemos contenido
if (!$input || !isset($input['contents'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Formato de request inválido. Se requiere campo "contents".']);
    logRequest($client_ip, false, 'Invalid request format');
    exit;
}

// Validar tamaño del contenido (máximo 4KB para la descripción)
$request_size = strlen(file_get_contents('php://input'));
if ($request_size > 4096) {
    http_response_code(413);
    echo json_encode(['error' => 'Descripción del evento muy larga (máx 4KB).']);
    logRequest($client_ip, false, 'Request too large');
    exit;
}

// ============= LLAMAR A GOOGLE GEMINI API =============

$api_url = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=' . urlencode($api_key);

// Obtener el referer original del cliente
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '';
if (empty($referer)) {
    // Si no hay referer, usar el origin o construir uno basado en el host
    $referer = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 
               (isset($_SERVER['HTTP_HOST']) ? 'https://' . $_SERVER['HTTP_HOST'] : 'https://staffeliteperu.com');
}

$ch = curl_init($api_url);

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($input));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'User-Agent: Staff-Elite-Peru/1.0',
    'Referer: ' . $referer
]);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curl_error = curl_error($ch);

curl_close($ch);

// ============= MANEJAR RESPUESTA =============

if ($curl_error) {
    http_response_code(502);
    echo json_encode(['error' => 'Error conectando con Google Gemini API: ' . $curl_error]);
    logRequest($client_ip, false, 'Curl error: ' . $curl_error);
    exit;
}

if ($http_code !== 200) {
    http_response_code($http_code);
    $error_data = json_decode($response, true);
    $error_msg = $error_data['error']['message'] ?? 'Error desconocido de API';
    echo json_encode(['error' => 'Google API Error: ' . $error_msg]);
    logRequest($client_ip, false, 'API returned ' . $http_code);
    exit;
}

// Respuesta exitosa
http_response_code(200);
echo $response;
logRequest($client_ip, true, 'Success');
exit;

// ============= FUNCIONES AUXILIARES =============

function logRequest($ip, $success, $status = '') {
    if (!is_dir(LOG_DIR)) {
        @mkdir(LOG_DIR, 0755, true);
    }
    
    $log_file = LOG_DIR . '/gemini-api-' . date('Y-m-d') . '.log';
    $log_entry = sprintf(
        "[%s] IP: %s | Status: %s | Details: %s\n",
        date('Y-m-d H:i:s'),
        $ip,
        $success ? 'SUCCESS' : 'FAILED',
        $status
    );
    
    @file_put_contents($log_file, $log_entry, FILE_APPEND);
}
?>
