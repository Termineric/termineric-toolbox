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
        $ElevateArgs = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($KeepExplorer) { $ElevateArgs += " -KeepExplorer" }
        if ($NoSteam)      { $ElevateArgs += " -NoSteam" }

        Start-Process powershell.exe -Verb RunAs -ArgumentList $ElevateArgs
        exit
    }
}

# Wildcards (*) allowed. Nothing is disabled: everything returns after reboot.
$ProcessesToKill = @(
    # Browsers / chat / AI
    "chrome",
    "msedge",
    "firefox",
    "msedgewebview2",
    "WhatsApp*",
    "Discord",
    "Teams",
    "Skype",
    "claude*",
    "cowork-svc",
    "ChatGPT*",
    "ollama*",

    # Dev / design
    "Code",
    "Photoshop",
    "figma_agent",
    "duet",
    "httpd",
    "mysqld",

    # Microsoft extras
    "OneDrive*",
    "FileCoAuth",
    "FileSyncHelper",
    "SDXHelper",
    "PowerToys*",
    "Microsoft.CmdPal*",
    "Widget*",
    "CrossDeviceService",

    # Intel / HP / Logitech tray tools
    "DSATray",
    "IntelConnect",
    "ICPS",
    "IDBWM",
    "IntelGraphicsSoftware",
    "esrv",
    "hpwuschd2",
    "DisplayControl",
    "cthelper",
    "logioptionsplus*",
    "logi_crashpad_handler",
    "SetPoint",
    "KHALMNPR",
    "laclient"
)

# Stopped BEFORE the processes, otherwise they restart their own process.
$ServicesToStop = @(
    # Web / database
    "Apache2.4",
    "mysql",
    "IBG_gds_db",
    "IBS_gds_db",

    # AI apps
    "CodexSandboxService.OpenAI.Codex",
    "CoworkVMService",

    # Intel
    "DSAService",
    "DSAUpdateService",
    "ESRV_SVC_QUEENCREEK",
    "SystemUsageReportSvc_QUEENCREEK",
    "Intel Analytics Service",
    "Intel Connectivity Network Service",
    "Intel Provider Data Helper Service",
    "IntelConnectService",
    "IDBWM",
    "IntelCstService",
    "dptftcs",
    "igccservice",
    "XTU3SERVICE",

    # HP
    "HpTouchpointAnalyticsService",
    "HPDiagsCap",
    "HPSysInfoCap",
    "HPNetworkCap",
    "HPAppHelperCap",
    "HPDCService",
    "HPPrintScanDoctorService",

    # Printing / scanning
    "PrintNode",
    "DYMOConnectPnPService",
    "Spooler",
    "StiSvc",

    # Logitech / Office
    "OptionsPlusUpdaterService",
    "logi_lamparray_service",
    "ClickToRunSvc",

    # Remote / USB / virtualisation
    "sshd",
    "ssh-agent",
    "usbipd",
    "IpOverUsbSvc",
    "WebManagement",
    "LxssManager",
    "vmcompute",
    "hns",

    # Windows background
    "SysMain",
    "WSearch",
    "DiagTrack",
    "DPS",
    "DoSvc",
    "PcaSvc",
    "TrkWks",
    "lfsvc"
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

Write-Host "Stopping services..." -ForegroundColor Cyan

foreach ($svc in $ServicesToStop) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue

    if ($service -and $service.Status -eq "Running") {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "Closing processes..." -ForegroundColor Cyan

foreach ($proc in $ProcessesToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -ne $PID } |
        Stop-Process -Force -ErrorAction SilentlyContinue
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