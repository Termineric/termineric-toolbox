# ============================================================================
# gamemode.ps1
# ============================================================================

param(
    [switch]$KeepExplorer,
    [switch]$NoSteam,
    [switch]$NoSelfElevate
)

# Admin check
if (-not $NoSelfElevate) {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if (-not $IsAdmin) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

$ProcessesToKill = @(
    "chrome",
    "msedge",
    "firefox",
    "WhatsApp",
    "Discord",
    "Teams",
    "Skype",
    "OneDrive",
    "figma_agent",
    "Code",
    "code",
    "PowerToys",
    "PowerToys.Peek.UI",
    "PowerToys.ColorPickerUI",
    "PowerToys.QuickAccess",
    "Microsoft.CmdPal.UI",
    "Microsoft.CmdPal.Ext.PowerToys",
    "DSATray",
    "IntelConnect",
    "logioptionsplus_agent",
    "logioptionsplus_updater",
    "WidgetBoard",
    "mysqld"
)

$ServicesToStop = @(
    "SysMain",
    "WSearch",
    "SystemUsageReportSvc_QUEENCREEK",
    "DSAService",
    "DSAUpdateService",
    "Intel Analytics Service",
    "HpTouchpointAnalyticsService"
)

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " GAME MODE ACTIVATED" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
$totalRamMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
$freeRamMB  = [math]::Round($os.FreePhysicalMemory / 1024, 0)

Write-Host "RAM BEFORE : $freeRamMB MB free of $totalRamMB MB" -ForegroundColor Yellow
Write-Host ""

Write-Host "Closing processes..." -ForegroundColor Cyan

foreach ($proc in $ProcessesToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Stopping services..." -ForegroundColor Cyan

foreach ($svc in $ServicesToStop) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue

    if ($service -and $service.Status -eq "Running") {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    }
}

if (-not $KeepExplorer) {
    Write-Host ""
    Write-Host "Closing Explorer..." -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Running memory cleanup..." -ForegroundColor Cyan

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
[System.GC]::Collect()

if (-not $NoSteam) {
    Write-Host ""
    Write-Host "Starting Steam..." -ForegroundColor Cyan
    Start-Process "steam://open/main" -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 3

$os2 = Get-CimInstance Win32_OperatingSystem
$freeRamMB2 = [math]::Round($os2.FreePhysicalMemory / 1024, 0)
$gain = $freeRamMB2 - $freeRamMB

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " GAME MODE READY" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

Write-Host "RAM AFTER  : $freeRamMB2 MB free" -ForegroundColor Green
Write-Host "RAM GAINED : $gain MB" -ForegroundColor Green
Write-Host ""

exit 0