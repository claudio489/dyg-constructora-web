# ============================================
# D&G Constructora - Deploy a GitHub
# ============================================
# PASOS:
# 1. Abre PowerShell COMO ADMINISTRADOR
# 2. Copia TODO este texto
# 3. Pégalo en PowerShell y presiona Enter
# ============================================

$ErrorActionPreference = "Stop"

# --- CONFIGURACION ---
$repoUrl = "https://github.com/claudio489/dyg-constructora-web.git"
$folder = "C:\Users\csilv\Downloads\DYG\dyg-v45-stable-working"
# ---------------------

Write-Host "========================================"
Write-Host "  D&G Constructora - Deploy GitHub"
Write-Host "========================================"
Write-Host ""

# Entrar a la carpeta
Set-Location $folder
Write-Host "Carpeta: $folder"

# Verificar que hay archivos
if (-not (Test-Path "index.html")) {
    Write-Host "ERROR: No hay index.html aqui. Verifica la carpeta." -ForegroundColor Red
    pause
    exit 1
}

# Paso 1: Inicializar git si no existe
Write-Host ""
Write-Host "[1/6] Inicializando Git..."
if (-not (Test-Path ".git")) {
    git init
    Write-Host "      Git inicializado" -ForegroundColor Green
} else {
    Write-Host "      Git ya existe" -ForegroundColor Green
}

# Paso 2: Configurar usuario (necesario para commit)
Write-Host ""
Write-Host "[2/6] Configurando usuario Git..."
git config user.email "deploy@dygconstructora.cl" 2>$null
git config user.name "Deploy Script" 2>$null
Write-Host "      Usuario configurado" -ForegroundColor Green

# Paso 3: Conectar con GitHub
Write-Host ""
Write-Host "[3/6] Conectando con GitHub..."
git remote remove origin 2>$null
git remote add origin $repoUrl
Write-Host "      Conectado a: $repoUrl" -ForegroundColor Green

# Paso 4: Agregar todos los archivos
Write-Host ""
Write-Host "[4/6] Agregando archivos..."
git add .
$archivos = (git status --short).Count
Write-Host "      $archivos archivos nuevos/modificados" -ForegroundColor Green

# Paso 5: Commit
Write-Host ""
Write-Host "[5/6] Creando commit..."
git commit -m "v48: Hero oscuro, Quienes Somos, Equipo, QR/vCard, Deck 2026, PWA, 21 proyectos" --allow-empty
Write-Host "      Commit creado" -ForegroundColor Green

# Paso 6: Push forzado
Write-Host ""
Write-Host "[6/6] Subiendo a GitHub (main)..."
git branch -M main

# Intentar push
try {
    git push -f origin main
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  PUSH EXITOSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Espera 2-3 minutos y revisa:" -ForegroundColor White
    Write-Host "  https://dyg-constructora-web.netlify.app/" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "ERROR en el push. Intenta manualmente:" -ForegroundColor Red
    Write-Host "  git push -f origin main" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..."
pause
