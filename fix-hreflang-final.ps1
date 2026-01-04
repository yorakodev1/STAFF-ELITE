# Script para corregir encoding en comentarios hreflang (regex flexible)
# Fecha: 2026-01-04

Write-Host "=== CORRIGIENDO COMENTARIOS HREFLANG ===" -ForegroundColor Cyan

$basePath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"
$archivos = @()

# Blog
$archivos += Get-ChildItem "$basePath\blog" -Filter "*.html"

# Landing
$archivos += Get-ChildItem "$basePath\landing" -Filter "*.html"

# Pages específicos
$archivos += Get-ChildItem "$basePath\pages\politica-privacidad.html"
$archivos += Get-ChildItem "$basePath\pages\terminos-condiciones.html"

$contador = 0

foreach ($archivo in $archivos) {
    $path = $archivo.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $before = $content
    
    # Reemplazar con regex flexible para capturar variantes de encoding
    $content = $content -replace 'localizaci.{1,6}n geogr.{1,6}fica', 'localización geográfica'
    
    if ($content -ne $before) {
        [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
        $contador++
        Write-Host "  OK $($archivo.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos corregidos: $contador" -ForegroundColor Green
