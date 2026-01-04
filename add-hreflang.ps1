# Script: Agregar hreflang tags a todas las páginas HTML
# Staff Elite Perú - Optimización SEO Internacional
# Fecha: 2025-12-31

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

$hreflangBlock = @"
   
   <!-- Hreflang para localización geográfica (SEO Internacional) -->
   <link rel="alternate" hreflang="es-PE" href="CANONICAL_URL" />
   <link rel="alternate" hreflang="es" href="CANONICAL_URL" />
   <link rel="alternate" hreflang="x-default" href="CANONICAL_URL" />
"@

Write-Host "=== AGREGANDO HREFLANG TAGS ===" -ForegroundColor Cyan
Write-Host ""

# Obtener todos los archivos HTML
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -Exclude "*old*","*backup*","test-*" | 
             Where-Object { $_.FullName -notmatch '\\old\\' }

Write-Host "Archivos a procesar: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$processed = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Verificar si ya tiene hreflang
    if ($content -match 'hreflang=') {
        Write-Host "SKIP $($file.Name): Ya tiene hreflang" -ForegroundColor Yellow
        continue
    }
    
    # Extraer la URL canonical
    if ($content -match '<link rel="canonical" href="([^"]+)"') {
        $canonicalUrl = $Matches[1]
        
        # Crear el bloque hreflang personalizado
        $customHreflang = $hreflangBlock -replace 'CANONICAL_URL', $canonicalUrl
        
        # Insertar después del canonical
        $content = $content -replace '(<link rel="canonical" href="[^"]+">)', "`$1$customHreflang"
        
        # Guardar
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "OK $($file.Name): Hreflang agregado" -ForegroundColor Green
        $processed++
    }
    else {
        Write-Host "WARN $($file.Name): No tiene canonical tag" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $processed" -ForegroundColor Green
Write-Host "Total archivos: $($htmlFiles.Count)" -ForegroundColor White
