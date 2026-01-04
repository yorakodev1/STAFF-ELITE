# Script: Corregir encoding UTF-8 en TODOS los archivos HTML
# Staff Elite Perú - Fix Mojibake Automático
# Fecha: 2026-01-04

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

# Mapeo de caracteres mojibake → caracteres correctos (solo los más comunes)
$replacements = @{
    'Per�' = 'Perú'
    'c�mo' = 'cómo'
    'Inversi�n' = 'Inversión'
    'activaci�n' = 'activación'
    'T�tulo' = 'Título'
    '�xito' = 'Éxito'
    'l�deres' = 'líderes'
    '�xitos' = 'éxitos'
    'Recepci�n' = 'Recepción'
    'Desaf�o' = 'Desafío'
    'biling�e' = 'bilingüe'
    'ingl�s' = 'inglés'
    'atenci�n' = 'atención'
    'comit�' = 'comité'
    'M�s' = 'Más'
    'Campa�a' = 'Campaña'
    'capacitaci�n' = 'capacitación'
    'captaci�n' = 'captación'
    'Pr�ximo' = 'Próximo'
    '�lite' = 'Élite'
}

Write-Host "=== CORRIGIENDO ENCODING UTF-8 EN TODOS LOS ARCHIVOS HTML ===" -ForegroundColor Cyan
Write-Host ""

$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -Exclude "*old*","*backup*","test-*" | 
             Where-Object { $_.FullName -notmatch '\\old\\' }

Write-Host "Archivos a procesar: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$filesModified = 0
$totalReplacements = 0

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        $fileChanges = 0
        
        foreach ($mojibake in $replacements.Keys) {
            $correct = $replacements[$mojibake]
            $beforeCount = ([regex]::Matches($content, [regex]::Escape($mojibake))).Count
            
            if ($beforeCount -gt 0) {
                $content = $content -replace [regex]::Escape($mojibake), $correct
                $fileChanges += $beforeCount
            }
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "OK $($file.Name): $fileChanges correcciones" -ForegroundColor Green
            $filesModified++
            $totalReplacements += $fileChanges
        }
    }
    catch {
        Write-Host "ERROR en $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total de correcciones: $totalReplacements" -ForegroundColor Green
Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
