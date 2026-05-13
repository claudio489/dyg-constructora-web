# ============================================================
# Instalador D&G Final - Deck Comercial 2026
# Right Click -> "Run with PowerShell"
# ============================================================

$ErrorActionPreference = "Stop"

# ---- CONFIGURACION ----
$zipFile     = "C:\Users\csilv\Downloads\DYG\dyg-v45-stable-working\dyg-final.zip"
$projectDir  = "C:\Users\csilv\Downloads\DYG\dyg-v45-stable-working"
$backupDir   = "C:\Users\csilv\Downloads\DYG\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$tempExtract = "$env:TEMP\dyg_extract_$(Get-Random)"

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Instalador D&G - Deck Comercial 2026" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. VERIFICAR ZIP
# ============================================================
Write-Host "[1/8] Verificando archivo ZIP..." -ForegroundColor Cyan
if (-not (Test-Path $zipFile)) {
    Write-Host ""
    Write-Host "ERROR: No se encontro el ZIP" -ForegroundColor Red
    Write-Host "Esperado en: $zipFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Por favor copia 'dyg-final.zip' a la carpeta:" -ForegroundColor White
    Write-Host "  C:\Users\csilv\Downloads\DYG\dyg-v45-stable-working\" -ForegroundColor Yellow
    Read-Host "Presione Enter para salir"
    exit 1
}
$zipSize = [math]::Round((Get-Item $zipFile).Length / 1MB, 1)
Write-Host "      OK: dyg-final.zip ($zipSize MB)" -ForegroundColor Green

# ============================================================
# 2. VERIFICAR CARPETA DEL PROYECTO
# ============================================================
Write-Host "[2/8] Verificando carpeta del proyecto..." -ForegroundColor Cyan
if (-not (Test-Path $projectDir)) {
    Write-Host "      ERROR: No existe $projectDir" -ForegroundColor Red
    Read-Host "Presione Enter para salir"
    exit 1
}
Write-Host "      OK: $projectDir" -ForegroundColor Green

# ============================================================
# 3. BACKUP DE SEGURIDAD
# ============================================================
Write-Host "[3/8] Creando backup de seguridad..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
# Backup de archivos criticos
$filesToBackup = @("index.html", "deck.html", "DG_Constructora_Deck_2026.pdf")
foreach ($f in $filesToBackup) {
    $src = Join-Path $projectDir $f
    if (Test-Path $src) {
        Copy-Item $src $backupDir -Force -Recurse -ErrorAction SilentlyContinue
    }
}
# Backup de images si existe
if (Test-Path "$projectDir\images") {
    Copy-Item "$projectDir\images" $backupDir -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "      OK: Backup en $backupDir" -ForegroundColor Green

# ============================================================
# 4. DESCOMPRIMIR ZIP A CARPETA TEMPORAL
# ============================================================
Write-Host "[4/8] Descomprimiendo ZIP..." -ForegroundColor Cyan
if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null

Expand-Archive -Path $zipFile -DestinationPath $tempExtract -Force
Write-Host "      OK: Descomprimido en carpeta temporal" -ForegroundColor Green

# Verificar que el ZIP tiene la estructura correcta (carpeta dyg-final dentro)
$extractedItems = Get-ChildItem $tempExtract
if ($extractedItems.Count -eq 1 -and $extractedItems[0].PSIsContainer -and $extractedItems[0].Name -eq "dyg-final") {
    # El ZIP tiene carpeta raiz "dyg-final/", usar esa
    $sourceDir = "$tempExtract\dyg-final"
    Write-Host "      ZIP tiene carpeta raiz 'dyg-final/'" -ForegroundColor Gray
} else {
    # El ZIP no tiene carpeta raiz, usar directamente
    $sourceDir = $tempExtract
}

# ============================================================
# 5. VERIFICAR CONTENIDO DEL ZIP
# ============================================================
Write-Host "[5/8] Verificando contenido..." -ForegroundColor Cyan
$requiredFiles = @(
    "index.html",
    "deck.html",
    "DG_Constructora_Deck_2026.pdf"
)
$requiredDirs = @(
    "assets",
    "images\deck-preview"
)

$missing = @()
foreach ($f in $requiredFiles) {
    if (-not (Test-Path "$sourceDir\$f")) { $missing += $f }
}
foreach ($d in $requiredDirs) {
    if (-not (Test-Path "$sourceDir\$d")) { $missing += $d }
}

if ($missing.Count -gt 0) {
    Write-Host "      ERROR: Faltan archivos en el ZIP:" -ForegroundColor Red
    foreach ($m in $missing) { Write-Host "        - $m" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "El ZIP puede estar corrupto. Intenta descargarlo de nuevo." -ForegroundColor White
    Read-Host "Presione Enter para salir"
    exit 1
}

# Verificar imagenes
$imgCount = (Get-ChildItem "$sourceDir\images\deck-preview" -Filter "*.webp" -ErrorAction SilentlyContinue).Count
Write-Host "      OK: index.html, deck.html, PDF, assets/, $imgCount imagenes" -ForegroundColor Green

# ============================================================
# 6. COPIAR ARCHIVOS AL PROYECTO
# ============================================================
Write-Host "[6/8] Instalando archivos..." -ForegroundColor Cyan

# Copiar archivos de raiz
Copy-Item "$sourceDir\index.html" "$projectDir\index.html" -Force
Write-Host "      index.html -> raiz" -ForegroundColor Gray

Copy-Item "$sourceDir\deck.html" "$projectDir\deck.html" -Force
Write-Host "      deck.html -> raiz" -ForegroundColor Gray

Copy-Item "$sourceDir\DG_Constructora_Deck_2026.pdf" "$projectDir\DG_Constructora_Deck_2026.pdf" -Force
Write-Host "      PDF -> raiz" -ForegroundColor Gray

# Copiar assets (solo los que faltan o son nuevos)
if (Test-Path "$sourceDir\assets") {
    if (-not (Test-Path "$projectDir\assets")) { New-Item -ItemType Directory -Path "$projectDir\assets" -Force | Out-Null }
    Copy-Item "$sourceDir\assets\*" "$projectDir\assets\" -Force -Recurse
    $assetCount = (Get-ChildItem "$projectDir\assets" -Recurse -File).Count
    Write-Host "      assets/ -> $assetCount archivos" -ForegroundColor Gray
}

# Copiar imagenes del deck
if (Test-Path "$sourceDir\images\deck-preview") {
    if (-not (Test-Path "$projectDir\images\deck-preview")) { 
        New-Item -ItemType Directory -Path "$projectDir\images\deck-preview" -Force | Out-Null 
    }
    Copy-Item "$sourceDir\images\deck-preview\*" "$projectDir\images\deck-preview\" -Force
    Write-Host "      images/deck-preview/ -> 11 imagenes" -ForegroundColor Gray
}

# ============================================================
# 7. VERIFICACION FINAL
# ============================================================
Write-Host "[7/8] Verificando instalacion..." -ForegroundColor Cyan
$checks = @{
    "index.html" = Test-Path "$projectDir\index.html"
    "deck.html" = Test-Path "$projectDir\deck.html"
    "PDF" = Test-Path "$projectDir\DG_Constructora_Deck_2026.pdf"
    "assets/" = (Test-Path "$projectDir\assets") -and ((Get-ChildItem "$projectDir\assets" -Recurse -File).Count -gt 0)
    "images/deck-preview/" = (Test-Path "$projectDir\images\deck-preview") -and ((Get-ChildItem "$projectDir\images\deck-preview" -Filter "*.webp").Count -eq 11)
}

$allOk = $true
foreach ($check in $checks.GetEnumerator()) {
    if ($check.Value) {
        Write-Host "      [OK] $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "      [FALTA] $($check.Key)" -ForegroundColor Red
        $allOk = $false
    }
}

# ============================================================
# 8. GIT PUSH
# ============================================================
Write-Host "[8/8] Subiendo a GitHub..." -ForegroundColor Cyan
Set-Location $projectDir

try {
    git add .
    git commit -m "Actualiza con Deck Comercial 2026 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Out-Null
    git push origin main
    Write-Host "      OK: Subido a GitHub" -ForegroundColor Green
} catch {
    Write-Host "      ADVERTENCIA: No se pudo hacer git push automaticamente" -ForegroundColor Yellow
    Write-Host "      Puedes hacerlo manualmente despues:" -ForegroundColor White
    Write-Host "        git add ." -ForegroundColor Gray
    Write-Host '        git commit -m "Deck Comercial 2026"' -ForegroundColor Gray
    Write-Host "        git push origin main" -ForegroundColor Gray
}

# ============================================================
# LIMPIEZA
# ============================================================
Write-Host "Limpiando archivos temporales..." -ForegroundColor Gray
Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
# RESUMEN FINAL
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INSTALACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($allOk) {
    Write-Host "Todo instalado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "URLs a probar:" -ForegroundColor Cyan
    Write-Host "  https://dyg-constructora-web.netlify.app/" -ForegroundColor Yellow
    Write-Host "  https://dyg-constructora-web.netlify.app/deck.html" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Backup guardado en:" -ForegroundColor Gray
    Write-Host "  $backupDir" -ForegroundColor Gray
} else {
    Write-Host "Hubo problemas. Revisa los mensajes arriba." -ForegroundColor Red
}

Write-Host ""
Read-Host "Presione Enter para cerrar"
