# Script: Verificar y reportar problemas de encoding UTF-8
# Staff Elite Perú - Fix Mojibake
# Fecha: 2026-01-04

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

Write-Host "=== VERIFICANDO ENCODING UTF-8 EN ARCHIVOS HTML ===" -ForegroundColor Cyan
Write-Host ""

$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -Exclude "*old*","*backup*" | 
             Where-Object { $_.FullName -notmatch '\\old\\' }

$problemFiles = @()

foreach ($file in $htmlFiles) {
    try {
        # Leer como UTF-8
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Buscar caracteres mojibake comunes
        $hasMojibake = $false
        $issues = @()
        
        # Patrón 1: � (replacement character)
        if ($content -match '\ufffd') {
            $hasMojibake = $true
            $count = ([regex]::Matches($content, '\ufffd')).Count
            $issues += "� (replacement character): $count"
        }
        
        # Patrón 2: Secuencias sospechosas con caracteres de control
        if ($content -match '[\x80-\xFF]{2,}') {
            $hasMojibake = $true
            $issues += "Secuencias de bytes sospechosas"
        }
        
        # Patrón 3: Verificar si hay caracteres no imprimibles o raros
        if ($content -match '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]') {
            $hasMojibake = $true
            $issues += "Caracteres de control no estándar"
        }
        
        if ($hasMojibake) {
            $problemFiles += [PSCustomObject]@{
                File = $file.Name
                Path = $file.FullName
                Issues = $issues -join ", "
            }
        }
    }
    catch {
        Write-Host "ERROR leyendo $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
Write-Host ""

if ($problemFiles.Count -gt 0) {
    Write-Host "ARCHIVOS CON PROBLEMAS DE ENCODING:" -ForegroundColor Red
    Write-Host ""
    foreach ($file in $problemFiles) {
        Write-Host "$($file.File)" -ForegroundColor Yellow
        Write-Host "  $($file.Issues)" -ForegroundColor White
        Write-Host ""
    }
    Write-Host "Total archivos con problemas: $($problemFiles.Count)" -ForegroundColor Red
}
else {
    Write-Host "OK: Todos los archivos tienen encoding correcto" -ForegroundColor Green
}
