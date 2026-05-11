# 🔐 Controleer of script als admin draait, anders herstart met elevatie
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Herstart als Administrator vereist..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Ontwikkelmodus wordt gestart..." -ForegroundColor Cyan

# 🛑 Stop Windows-diensten die onnodig zijn tijdens development
$windowsServices = @("SysMain", "WSearch")
foreach ($service in $windowsServices) {
    Write-Host "Stoppen van Windows service: $service..."
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# 🔥 Kill apps die NIET nodig zijn in devmode
$killList = @(
    # Browsers
    "brave", "chrome", "firefox", "iexplore", "msedge", "opera", "safari", "vivaldi",
    # Cloud & communicatie
    "Discord", "OneDrive", "Signal", "Spotify", "Teams", "WhatsApp", "Zoom",
    # HP/Intel/Support
    "AppHelperCap", "CTHelper", "DiagsCap", "DisplayControl", "DisplayControlService", "DSAUpdateService",
    "DYMOConnectPnPService", "FileSyncHelper", "HPSF", "HPSupportAssistant", "HPSupportSolutionsFrameworkService",
    "hpwuschd2", "ibguard", "ibserver", "IntelAnalyticsService", "IntelAudioService", "IntelConnect",
    "IntelConnectService", "IntelConnectivityNetworkService", "IntelGraphicsSoftware", "IntelGraphicsSoftware.Service",
    "IntelProviderDataHelperService", "NetworkCap", "PresentMonService", "SysInfoCap", "XtuService", "UninstallMonitor", "Microsoft.SharePoint",
    # Windows extra’s & achtergrond
    "Cortana", "GameBar", "GameBarFTServer", "RuntimeBroker", "SearchHost", "SearchIndexer", "StartMenuExperienceHost",
    "Taskmgr", "TouchpointAnalyticsClientService", "Widgets", "WidgetBoard", "WidgetService", "YourPhone", "TabTip", "XboxGameBar",
    # Extra: Knipprogramma
    "SnippingTool", "SnipAndSketch"
    # PrintNode is hier UITGESLOTEN omdat je hem wél wilt draaien in devmode
    # "nssm_64", "PrintNodeService",
    # Dev/apps die je wilt laten draaien NIET toevoegen!
)

foreach ($proc in $killList) {
    $killed = $false
    Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Host "✅ $($proc).exe afgesloten (PID: $($_.Id))"
            $killed = $true
        } catch {
            Write-Host "⚠️  Kon $($proc).exe (PID: $($_.Id)) niet afsluiten: $($_.Exception.Message)"
        }
    }
    if (-not $killed) {
        Write-Host "ℹ️  $($proc).exe draaide niet."
    }
}

# 🟢 Start MariaDB (alleen als nodig)
$mysqldPath = "C:\tools\xampp\mysql\bin\mysqld.exe"
try {
    if (-not (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue)) {
        Write-Host "MariaDB wordt gestart..."
        Start-Process -FilePath $mysqldPath
        Start-Sleep -Seconds 3
        if (Get-Process -Name "mysqld" -ErrorAction SilentlyContinue) {
            Write-Host "✅ MariaDB (mysqld.exe) gestart."
        } else {
            Write-Host "❌ MariaDB is NIET gestart, controleer handmatig!" -ForegroundColor Red
        }
    } else {
        Write-Host "MariaDB draait al."
    }
} catch {
    Write-Host "Fout bij starten van MariaDB: $_" -ForegroundColor Red
}

# 🟢 Controleer en start overige dev-apps/server/services
$appsToCheck = @(
    @{ name = "phpstorm64";      path = "C:\Program Files\JetBrains\PhpStorm 2024.1.2\bin\phpstorm64.exe" },
    @{ name = "wampmanager";     path = "C:\tools\xampp\wampmanager.exe" }, # pas het pad aan!
    @{ name = "httpd";           path = "C:\tools\xampp\apache\bin\httpd.exe" },
    @{ name = "nssm_64";         path = "C:\Program Files\PrintNode\nssm_64.exe" }, # pas het pad aan!
    @{ name = "PrintNodeService"; path = "C:\Program Files\PrintNode\PrintNodeService.exe" }
)

foreach ($app in $appsToCheck) {
    if (-not (Get-Process -Name $app.name -ErrorAction SilentlyContinue)) {
        Write-Host "$($app.name) wordt gestart..."
        try {
            Start-Process -FilePath $app.path
            Start-Sleep -Seconds 2
            if (Get-Process -Name $app.name -ErrorAction SilentlyContinue) {
                Write-Host "✅ $($app.name) gestart."
            } else {
                Write-Host "❌ $($app.name) is NIET gestart, controleer handmatig!" -ForegroundColor Red
            }
        } catch {
            Write-Host "Fout bij starten van $($app.name): $_" -ForegroundColor Red
        }
    } else {
        Write-Host "$($app.name) draait al."
    }
}

# 🛑 Stop Ollama via je toolbox-script
Write-Host "Stop Ollama backend + GUI via stop-ollama.ps1..." -ForegroundColor Yellow
& "$PSScriptRoot\stop-ollama.ps1"

Write-Host "✅ Ontwikkelmodus actief." -ForegroundColor Green
