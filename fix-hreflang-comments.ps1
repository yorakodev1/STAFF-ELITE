# Script para corregir el encoding en comentarios hreflang
# Fecha: 2026-01-04

Write-Host "=== CORRIGIENDO COMENTARIOS HREFLANG ===" -ForegroundColor Cyan

$basePath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"
$archivos = @()

# Blog
$archivos += Get-ChildItem "$basePath\blog" -Filter "*.html" | Where-Object { $_.Name -notlike "index*" }

# Landing  
$archivos += Get-ChildItem "$basePath\landing" -Filter "*.html"

# Pages
$archivos += @("$basePath\pages\politica-privacidad.html", "$basePath\pages\terminos-condiciones.html")

$contador = 0

foreach ($archivo in $archivos) {
    $path = if ($archivo -is [string]) { $archivo } else { $archivo.FullName }
    
    $contenido = Get-Content $path -Raw -Encoding UTF8
    $nuevo = $contenido -replace 'localizaciÃ³n geogrÃ¡fica', 'localización geográfica'
    
    if ($contenido -ne $nuevo) {
        $nuevo | Set-Content $path -Encoding UTF8 -NoNewline
        $contador++
        $nombreArchivo = Split-Path $path -Leaf
        Write-Host "  OK $nombreArchivo" -ForegroundColor Green
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos corregidos: $contador" -ForegroundColor Green
