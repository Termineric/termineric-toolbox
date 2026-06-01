# =========================================================
# Basic Laravel + Auth + AdminLTE Site Builder
# Run from project root folder
# =========================================================

$root = (Get-Location).Path
$projectName = Split-Path $root -Leaf

if ($projectName -eq "Laravel-Source") {
    Write-Host "[ERROR] Run this command from the project root, not inside Laravel-Source."
    exit 1
}

$laravelPath = Join-Path $root "Laravel-Source"

Write-Host ""
Write-Host "========================================="
Write-Host " BASIC LARAVEL SITE BUILDER"
Write-Host "========================================="
Write-Host ""

if (-not (Test-Path $laravelPath)) {
    New-Item -ItemType Directory -Path $laravelPath | Out-Null
    Write-Host "[OK] Laravel-Source folder created"
}

if (Test-Path (Join-Path $laravelPath "artisan")) {
    Write-Host "[ERROR] Laravel already installed:"
    Write-Host $laravelPath
    exit 1
}

# =========================================================
# STEP 1 - Install Laravel
# =========================================================

Write-Host "[1/6] Installing Laravel..."

Set-Location $laravelPath

composer create-project laravel/laravel .

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Laravel installation failed."
    exit 1
}

# =========================================================
# STEP 2 - Install Laravel UI auth
# =========================================================

Write-Host "[2/6] Installing Laravel UI..."

composer require laravel/ui

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] laravel/ui installation failed."
    exit 1
}

php artisan ui bootstrap --auth

# =========================================================
# STEP 3 - Install AdminLTE
# =========================================================

Write-Host "[3/6] Installing AdminLTE..."

composer require jeroennoten/laravel-adminlte

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] AdminLTE installation failed."
    exit 1
}

php artisan adminlte:install

# =========================================================
# STEP 4 - Install frontend packages
# =========================================================

Write-Host "[4/6] Installing npm packages..."

npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] npm install failed."
    exit 1
}

npm run build

# =========================================================
# STEP 5 - Create basic roles migration
# =========================================================

Write-Host "[5/6] Creating basic roles migration..."

php artisan make:migration create_roles_table

# =========================================================
# STEP 6 - Done
# =========================================================

Set-Location $root

Write-Host ""
Write-Host "========================================="
Write-Host " LARAVEL BASE READY"
Write-Host "========================================="
Write-Host ""

Write-Host "Next:"
Write-Host "cd Laravel-Source"
Write-Host "php artisan serve"
Write-Host ""