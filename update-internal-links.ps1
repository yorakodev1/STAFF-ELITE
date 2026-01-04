# Script: Actualizar TODAS las referencias internas de underscores a hyphens
# Staff Elite Perú - Optimización SEO
# Fecha: 2025-12-31

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

# Mapeo de URLs antiguas → nuevas (sin paths, solo nombres de archivo)
$urlMappings = @{
    # Landing pages
    'anfitrionas_peru.html' = 'anfitrionas-peru.html'
    'anfitrionas_lima.html' = 'anfitrionas-lima.html'
    'anfitrionas_trujillo.html' = 'anfitrionas-trujillo.html'
    'promotoras_arequipa.html' = 'promotoras-arequipa.html'
    'promotoras_btl.html' = 'promotoras-btl.html'
    'protocolo_vip.html' = 'protocolo-vip.html'
    
    # Blog posts
    'activaciones_marca_btl.html' = 'activaciones-marca-btl.html'
    'anfitrionas_congresos.html' = 'anfitrionas-congresos.html'
    'anfitrionas_eventos.html' = 'anfitrionas-eventos.html'
    'anfitrionas_ferias.html' = 'anfitrionas-ferias.html'
    'anfitrionas_imagen.html' = 'anfitrionas-imagen.html'
    'animadores_marca_eventos.html' = 'animadores-marca-eventos.html'
    'checklist_contratar_staff.html' = 'checklist-contratar-staff.html'
    'coordinadores_eventos.html' = 'coordinadores-eventos.html'
    'diferencia_anfitrionas_promotoras.html' = 'diferencia-anfitrionas-promotoras.html'
    'maestros_ceremonia.html' = 'maestros-ceremonia.html'
    'modelos_profesionales.html' = 'modelos-profesionales.html'
    'personal_protocolo.html' = 'personal-protocolo.html'
    'precios_anfitrionas_peru.html' = 'precios-anfitrionas-peru.html'
    'promotores_venta.html' = 'promotores-venta.html'
    'sesion_fotos_profesional.html' = 'sesion-fotos-profesional.html'
    'uniformes_personalizados_anfitrionas.html' = 'uniformes-personalizados-anfitrionas.html'
    
    # Pages
    'casos_de_exito.html' = 'casos-de-exito.html'
    'herramienta_calculadora_roi.html' = 'herramienta-calculadora-roi.html'
}

Write-Host "=== INICIANDO ACTUALIZACION DE ENLACES INTERNOS ===" -ForegroundColor Cyan
Write-Host ""

# Obtener todos los archivos HTML (excluyendo /old)
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -Exclude "*old*","*backup*","test-*" | 
             Where-Object { $_.FullName -notmatch '\\old\\' }

Write-Host "Archivos HTML a procesar: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$filesModified = 0
$totalReplacements = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileReplacements = 0
    
    # Para cada mapeo, reemplazar TODAS las variantes posibles
    foreach ($oldName in $urlMappings.Keys) {
        $newName = $urlMappings[$oldName]
        
        # Variante 1: href="/landing/archivo_viejo.html"
        $content = $content -replace "href=`"(/landing/)$oldName`"", "href=`"`$1$newName`""
        
        # Variante 2: href="/blog/archivo_viejo.html"
        $content = $content -replace "href=`"(/blog/)$oldName`"", "href=`"`$1$newName`""
        
        # Variante 3: href="/pages/archivo_viejo.html"
        $content = $content -replace "href=`"(/pages/)$oldName`"", "href=`"`$1$newName`""
        
        # Variante 4: href="../landing/archivo_viejo.html" (relativas)
        $content = $content -replace "href=`"(\.\./landing/)$oldName`"", "href=`"`$1$newName`""
        $content = $content -replace "href=`"(\.\./blog/)$oldName`"", "href=`"`$1$newName`""
        $content = $content -replace "href=`"(\.\./pages/)$oldName`"", "href=`"`$1$newName`""
        
        # Variante 5: href="archivo_viejo.html" (mismo directorio)
        $content = $content -replace "href=`"$oldName`"", "href=`"$newName`""
        
        # Variante 6: URLs completas en canonical, og:url, schema, etc.
        $content = $content -replace "staffeliteperu\.com/landing/$oldName", "staffeliteperu.com/landing/$newName"
        $content = $content -replace "staffeliteperu\.com/blog/$oldName", "staffeliteperu.com/blog/$newName"
        $content = $content -replace "staffeliteperu\.com/pages/$oldName", "staffeliteperu.com/pages/$newName"
    }
    
    # Si hubo cambios, guardar el archivo
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $replacementCount = ([regex]::Matches($originalContent, '_[a-z]+\.html')).Count - ([regex]::Matches($content, '_[a-z]+\.html')).Count
        Write-Host "OK $($file.Name): ~$replacementCount reemplazos" -ForegroundColor Green
        $filesModified++
        $totalReplacements += $replacementCount
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total estimado de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
