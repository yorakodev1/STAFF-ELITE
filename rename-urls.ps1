# Script de Renombrado de URLs: underscores → hyphens
# Staff Elite Perú - Optimización SEO
# Fecha: 2025-12-31

$rootPath = "a:\PROYECTOS\LANDINGS ANFITRIONAS\STAFF ELITE"

# Arrays de mapeo: [nombre_antiguo, nombre_nuevo]
$renameMappings = @(
    # Landing pages (6 archivos)
    @("landing\anfitrionas_peru.html", "landing\anfitrionas-peru.html"),
    @("landing\anfitrionas_lima.html", "landing\anfitrionas-lima.html"),
    @("landing\anfitrionas_trujillo.html", "landing\anfitrionas-trujillo.html"),
    @("landing\promotoras_arequipa.html", "landing\promotoras-arequipa.html"),
    @("landing\promotoras_btl.html", "landing\promotoras-btl.html"),
    @("landing\protocolo_vip.html", "landing\protocolo-vip.html"),
    
    # Blog posts (16 archivos)
    @("blog\activaciones_marca_btl.html", "blog\activaciones-marca-btl.html"),
    @("blog\anfitrionas_congresos.html", "blog\anfitrionas-congresos.html"),
    @("blog\anfitrionas_eventos.html", "blog\anfitrionas-eventos.html"),
    @("blog\anfitrionas_ferias.html", "blog\anfitrionas-ferias.html"),
    @("blog\anfitrionas_imagen.html", "blog\anfitrionas-imagen.html"),
    @("blog\animadores_marca_eventos.html", "blog\animadores-marca-eventos.html"),
    @("blog\checklist_contratar_staff.html", "blog\checklist-contratar-staff.html"),
    @("blog\coordinadores_eventos.html", "blog\coordinadores-eventos.html"),
    @("blog\diferencia_anfitrionas_promotoras.html", "blog\diferencia-anfitrionas-promotoras.html"),
    @("blog\maestros_ceremonia.html", "blog\maestros-ceremonia.html"),
    @("blog\modelos_profesionales.html", "blog\modelos-profesionales.html"),
    @("blog\personal_protocolo.html", "blog\personal-protocolo.html"),
    @("blog\precios_anfitrionas_peru.html", "blog\precios-anfitrionas-peru.html"),
    @("blog\promotores_venta.html", "blog\promotores-venta.html"),
    @("blog\sesion_fotos_profesional.html", "blog\sesion-fotos-profesional.html"),
    @("blog\uniformes_personalizados_anfitrionas.html", "blog\uniformes-personalizados-anfitrionas.html"),
    
    # Pages (2 archivos ya tienen hyphens, no renombramos: politica-privacidad.html, terminos-condiciones.html)
    @("pages\casos_de_exito.html", "pages\casos-de-exito.html"),
    @("pages\herramienta_calculadora_roi.html", "pages\herramienta-calculadora-roi.html")
)

Write-Host "=== INICIANDO RENOMBRADO DE ARCHIVOS ===" -ForegroundColor Cyan
Write-Host "Total de archivos a renombrar: $($renameMappings.Count)" -ForegroundColor Yellow
Write-Host ""

$renamed = 0
$errors = 0

foreach ($mapping in $renameMappings) {
    $oldPath = Join-Path $rootPath $mapping[0]
    $newPath = Join-Path $rootPath $mapping[1]
    
    if (Test-Path $oldPath) {
        try {
            Rename-Item -Path $oldPath -NewName (Split-Path $newPath -Leaf) -ErrorAction Stop
            Write-Host "OK Renombrado: $($mapping[0]) -> $($mapping[1])" -ForegroundColor Green
            $renamed++
        }
        catch {
            Write-Host "ERROR: $($mapping[0]) - $($_.Exception.Message)" -ForegroundColor Red
            $errors++
        }
    }
    else {
        Write-Host "WARNING No encontrado: $oldPath" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Renombrados exitosamente: $renamed" -ForegroundColor Green
Write-Host "Errores: $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
Write-Host "Total procesado: $($renamed + $errors)" -ForegroundColor White
