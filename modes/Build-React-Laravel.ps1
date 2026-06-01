# =========================================================
# Universal React -> Laravel Build Script
# Run this from the project root folder
# =========================================================

$root = (Get-Location).Path

$frontend = Join-Path $root "React-Source"
$laravel = Join-Path $root "Laravel-Source"
$laravelPublic = Join-Path $laravel "public"

Write-Host ""
Write-Host "========================================="
Write-Host " REACT -> LARAVEL BUILD SCRIPT"
Write-Host "========================================="
Write-Host ""
Write-Host "Project root: $root"
Write-Host ""

# =========================================================
# VALIDATE FOLDERS
# =========================================================

if (-not (Test-Path $frontend)) {
    Write-Host "[ERROR] React-Source folder not found:"
    Write-Host $frontend
    exit 1
}

if (-not (Test-Path $laravel)) {
    Write-Host "[ERROR] Laravel-Source folder not found:"
    Write-Host $laravel
    exit 1
}

if (-not (Test-Path $laravelPublic)) {
    Write-Host "[ERROR] Laravel public folder not found:"
    Write-Host $laravelPublic
    exit 1
}

# =========================================================
# STEP 1 - React build
# =========================================================

Write-Host "[1/5] Build React frontend..."

Set-Location $frontend

npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] React build FAILED!"
    exit 1
}

# =========================================================
# STEP 2 - Cleanup old assets
# =========================================================

Write-Host "[2/5] Cleanup old Laravel public assets..."

if (Test-Path "$laravelPublic\assets") {
    Remove-Item "$laravelPublic\assets" -Recurse -Force
}

if (Test-Path "$laravelPublic\index.html") {
    Remove-Item "$laravelPublic\index.html" -Force
}

# =========================================================
# STEP 3 - Copy new React build
# =========================================================

Write-Host "[3/5] Copy React dist to Laravel public..."

Copy-Item "$frontend\dist\*" $laravelPublic -Recurse -Force

# =========================================================
# STEP 4 - Laravel cleanup
# =========================================================

Write-Host "[4/5] Clear Laravel caches..."

Set-Location $laravel

php artisan optimize:clear

# =========================================================
# STEP 5 - Done
# =========================================================

Set-Location $root

Write-Host ""
Write-Host "========================================="
Write-Host " BUILD COMPLETE"
Write-Host "========================================="
Write-Host ""

Write-Host "Project root:"
Write-Host $root
Write-Host ""

Write-Host "Laravel site:"
Write-Host "http://127.0.0.1:8000"
Write-Host ""