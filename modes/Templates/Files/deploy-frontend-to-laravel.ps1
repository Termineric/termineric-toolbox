# =========================================================
# Insulinde React -> Laravel Build Script
# =========================================================

$root = "C:\Project-List\mobatech"

$frontend = "$root\React-Source"
$laravel = "$root\Laravel-Source"
$laravelPublic = "$laravel\public"

Write-Host ""
Write-Host "========================================="
Write-Host " INSULINDE BUILD SCRIPT"
Write-Host "========================================="
Write-Host ""

# =========================================================
# STEP 1 - React build
# =========================================================

Write-Host "[1/5] Build React frontend..."

Set-Location $frontend

npm run build

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "React build FAILED!"
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

Write-Host ""
Write-Host "========================================="
Write-Host " BUILD COMPLETE"
Write-Host "========================================="
Write-Host ""

Write-Host "Laravel site:"
Write-Host "http://127.0.0.1:8000"
Write-Host ""