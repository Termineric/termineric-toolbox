Write-Host "🔍 Analyse: Problemen met vensters slepen" -ForegroundColor Cyan

# 1. Controleren of DragFullWindows aan staat
$dragFullWindows = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -ErrorAction SilentlyContinue
if ($dragFullWindows.DragFullWindows -eq "1") {
    Write-Host "✅ Vensters slepen toont inhoud (DragFullWindows = 1)" -ForegroundColor Green
} elseif ($null -ne $dragFullWindows.DragFullWindows) {
    Write-Host "❌ Vensters slepen toont GEEN inhoud (DragFullWindows = $($dragFullWindows.DragFullWindows))" -ForegroundColor Red
} else {
    Write-Host "⚠️  Kan waarde 'DragFullWindows' niet uitlezen." -ForegroundColor DarkYellow
}

# 2. Actieve GPU-gerelateerde processen
Write-Host "`n🖼 Actieve GPU-gerelateerde processen:"
Get-Process | Where-Object { $_.Name -match "amd|nvidia|intel|gpu|display" } | Select-Object Name, Id

# 3. Huidige schaalinstelling (DPI scaling)
$dpiSetting = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -ErrorAction SilentlyContinue
if ($dpiSetting.LogPixels) {
    $percentage = [math]::Round($dpiSetting.LogPixels / 96 * 100)
    Write-Host "🔎 Huidige schaalinstelling: $percentage%" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Kon DPI-instelling (LogPixels) niet uitlezen." -ForegroundColor DarkYellow
}

# 4. Mogelijke storende software
$mogelijkStorend = @(
    "HPDisplay", "HPSupport", "HPOmen", "DellDisplay", "DDM", "igfx", "NVIDIA", "Intel", "Nahimic", "Acer", "Lenovo"
)

Write-Host "`n🧪 Mogelijk storende software die actief is:"
foreach ($naam in $mogelijkStorend) {
    $match = Get-Process | Where-Object { $_.Name -like "*$naam*" } -ErrorAction SilentlyContinue
    if ($match) {
        foreach ($p in $match) {
            Write-Host "⚠️  Actief: $($p.Name)" -ForegroundColor Red
        }
    }
}

Write-Host "`n✅ Analyse voltooid." -ForegroundColor Cyan
