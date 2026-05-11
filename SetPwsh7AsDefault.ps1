# Pad naar Windows Terminal settings.json
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Pad naar PowerShell 7
$pwshPath = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"

# Lees huidige settings
$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# Controleer of profiel al bestaat
$existing = $settings.profiles.list | Where-Object { $_.commandline -eq $pwshPath }

if (-not $existing) {
    # Voeg PowerShell 7 profiel toe
    $newProfile = @{
        name = "PowerShell 7"
        commandline = $pwshPath
        hidden = $false
        guid = "{3c5d8aa3-743e-4c48-b688-f513dfb1f7ae}"
    }
    $settings.profiles.list += $newProfile
    Write-Host "✅ PowerShell 7 profiel toegevoegd."
} else {
    Write-Host "ℹ️ PowerShell 7 profiel bestond al."
}

# Zet als standaard
$settings.defaultProfile = "{3c5d8aa3-743e-4c48-b688-f513dfb1f7ae}"

# Opslaan
$settings | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath -Encoding utf8

Write-Host "`n🎉 PowerShell 7 is nu standaard in Windows Terminal!"
