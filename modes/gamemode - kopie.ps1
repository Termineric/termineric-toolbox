# 🔐 Check admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Herstart als Administrator vereist..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "🎮 Game-modus wordt gestart..." -ForegroundColor Cyan

# Sluit niet-essentiële processen
# $killList = @(
#     "chrome", "firefox", "msedge", "brave", "vivaldi", "opera", "iexplore", "safari",
#     "OneDrive", "Teams", "Zoom", "Discord", "Spotify", "Signal", "WhatsApp",
#     "phpstorm64", "code", "idea64", "datagrip64", "ollama", "ollama app", "Ollama",
#     "wampmanager", "mysqld", "httpd", "node", "ngrok",
#     "YourPhone", "Widgets", "Cortana", "RuntimeBroker", "StartMenuExperienceHost", "SearchIndexer",
#     "XboxGameBar", "GameBar", "GameBarFTServer"
# )

$killList = @(
    # Browsers
    "brave", "chrome", "firefox", "iexplore", "msedge", "opera", "safari", "vivaldi",

    # Cloud & communicatie
    "Discord", "OneDrive", "Signal", "Spotify", "Teams", "WhatsApp", "Zoom",

    # Dev/tools
    "code", "Code", "datagrip64", "idea64", "ngrok", "node", "ollama", "ollama app", "Ollama",
    "phpstorm64", "wampmanager", "mysqld", "httpd",

    # PrintNode
    "nssm_64", "PrintNodeService",

    # HP/Printer/Intel/Support
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
)


foreach ($proc in $killList) {
    Write-Host "Sluiten van $proc.exe (indien actief)..."
    Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
}

# Sluit ALLE explorer-processen (taakbalk, vensters)
Write-Host "Sluiten van ALLE Windows Verkenner (explorer.exe, incl. taakbalk)..."
Get-Process -Name explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2 # even wachten tot alles echt afgesloten is



# Stop zware Windows services
$services = @("SysMain","WSearch","MapsBroker","DiagTrack","PrintNotify")
foreach ($service in $services) {
    Write-Host "Stoppen van Windows service: $service..."
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# Start Steam als nodig
if (-not (Get-Process -Name "steam" -ErrorAction SilentlyContinue)) {
    Write-Host "Steam wordt gestart..."
    Start-Process "C:\Program Files (x86)\Steam\steam.exe"
    Start-Sleep -Seconds 7
}

# Start 1 nieuwe explorer.exe (voor taakbalk & bureaublad)
# Explorer (taakbalk/bureaublad) alleen starten indien nodig:
if (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
    Write-Host "explorer.exe draait niet, wordt nu gestart..."
    Start-Process explorer.exe
    Write-Host "✅ explorer.exe is gestart."
} else {
    Write-Host "explorer.exe draait al, starten is niet nodig."
}

Write-Host "✅ Game-modus actief! Alles opgeschoond." -ForegroundColor Green