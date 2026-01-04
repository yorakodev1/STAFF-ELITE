# Script: Actualizar URLs de Redes Sociales
# Staff Elite Perú - SEO & Branding
# Fecha: 2025-12-31

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

# URLs CORRECTAS de Staff Elite Perú
$socialUrls = @{
    'https://www.facebook.com/' = 'https://www.facebook.com/staffeliteperu'
    'https://facebook.com/' = 'https://www.facebook.com/staffeliteperu'
    'https://www.instagram.com/' = 'https://www.instagram.com/staffeliteperu'
    'https://instagram.com/' = 'https://www.instagram.com/staffeliteperu'
    'https://www.linkedin.com/' = 'https://www.linkedin.com/company/staff-elite-peru'
    'https://linkedin.com/' = 'https://www.linkedin.com/company/staff-elite-peru'
    'https://www.twitter.com/' = 'https://twitter.com/staffeliteperu'
    'https://twitter.com/' = 'https://twitter.com/staffeliteperu'
}

Write-Host "=== ACTUALIZANDO URLs DE REDES SOCIALES ===" -ForegroundColor Cyan
Write-Host ""

$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -Exclude "*old*","*backup*" | 
             Where-Object { $_.FullName -notmatch '\\old\\' }

Write-Host "Archivos a procesar: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$filesModified = 0
$totalReplacements = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileChanges = 0
    
    foreach ($genericUrl in $socialUrls.Keys) {
        $specificUrl = $socialUrls[$genericUrl]
        
        # Contar ocurrencias antes del reemplazo
        $beforeCount = ([regex]::Matches($content, [regex]::Escape($genericUrl))).Count
        
        if ($beforeCount -gt 0) {
            $content = $content -replace [regex]::Escape($genericUrl), $specificUrl
            $fileChanges += $beforeCount
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "OK $($file.Name): $fileChanges URLs actualizadas" -ForegroundColor Green
        $filesModified++
        $totalReplacements += $fileChanges
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total de URLs actualizadas: $totalReplacements" -ForegroundColor Green
Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
