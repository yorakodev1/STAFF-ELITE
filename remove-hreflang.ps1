# Script para eliminar hreflang tags conflictivos (Issue #24)
# Fecha: 2026-01-04

Write-Host "=== ELIMINANDO HREFLANG TAGS CONFLICTIVOS ===" -ForegroundColor Cyan

$basePath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"
$archivos = @()

# Index
$archivos += Get-Item "$basePath\index.html"

# Blog
$archivos += Get-ChildItem "$basePath\blog" -Filter "*.html"

# Landing
$archivos += Get-ChildItem "$basePath\landing" -Filter "*.html"

# Pages
$archivos += Get-ChildItem "$basePath\pages" -Filter "*.html" -Exclude "test-proxy.html"

$contador = 0

foreach ($archivo in $archivos) {
    $path = $archivo.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $before = $content
    
    # Eliminar comentario hreflang (con encoding corrupto o correcto)
    $content = $content -replace '\s*<!--\s*Hreflang.*?-->\s*\r?\n', ''
    
    # Eliminar las 3 líneas de hreflang
    $content = $content -replace '\s*<link rel="alternate" hreflang="es-PE".*?/>\s*\r?\n', ''
    $content = $content -replace '\s*<link rel="alternate" hreflang="es".*?/>\s*\r?\n', ''
    $content = $content -replace '\s*<link rel="alternate" hreflang="x-default".*?/>\s*\r?\n', ''
    
    if ($content -ne $before) {
        [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
        $contador++
        $nombreArchivo = Split-Path $path -Leaf
        Write-Host "  OK $nombreArchivo" -ForegroundColor Green
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos modificados: $contador" -ForegroundColor Green
Write-Host "Hreflang tags eliminados exitosamente (Issue #24 resuelto)" -ForegroundColor Green
