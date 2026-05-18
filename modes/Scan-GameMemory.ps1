# ============================================================================
# Scan-GameMemory.ps1
# Scan RAM usage and running processes for Game Mode optimization.
# ============================================================================

$BaseDir = "C:\Project-List\termineric-toolbox\modes\GameModeScan"

New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null

$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$OverviewFile = "$BaseDir\memory_overview_$TimeStamp.txt"
$ProcessCsv   = "$BaseDir\memory_processes_$TimeStamp.csv"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " GAME MODE MEMORY SCAN"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Output folder:" -ForegroundColor Yellow
Write-Host $BaseDir
Write-Host ""

# ============================================================================
# MEMORY INFO
# ============================================================================

$os = Get-CimInstance Win32_OperatingSystem

$totalRamMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
$freeRamMB  = [math]::Round($os.FreePhysicalMemory / 1024, 0)
$usedRamMB  = $totalRamMB - $freeRamMB

"==================================================" | Out-File $OverviewFile -Encoding UTF8
" MEMORY STATUS"
"==================================================" | Add-Content $OverviewFile

"Total RAM : $totalRamMB MB" | Add-Content $OverviewFile
"Used RAM  : $usedRamMB MB" | Add-Content $OverviewFile
"Free RAM  : $freeRamMB MB" | Add-Content $OverviewFile

# ============================================================================
# PROCESS LIST
# ============================================================================

"`n==================================================" | Add-Content $OverviewFile
" TOP RAM PROCESSES"
"==================================================" | Add-Content $OverviewFile

Get-Process |
    Select-Object `
        ProcessName,
        Id,
        @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet64 / 1MB, 1)}},
        CPU |
    Sort-Object MemoryMB -Descending |
    Export-Csv -Path $ProcessCsv -NoTypeInformation -Encoding UTF8

Import-Csv $ProcessCsv |
    Select-Object -First 100 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content $OverviewFile

# ============================================================================
# SERVICES
# ============================================================================

"`n==================================================" | Add-Content $OverviewFile
" RUNNING SERVICES"
"==================================================" | Add-Content $OverviewFile

Get-Service |
    Where-Object { $_.Status -eq "Running" } |
    Sort-Object DisplayName |
    Format-Table Name, DisplayName, StartType -AutoSize |
    Out-String |
    Add-Content $OverviewFile

# ============================================================================
# DONE
# ============================================================================

Write-Host ""
Write-Host "DONE." -ForegroundColor Green
Write-Host ""
Write-Host "Overview file:" -ForegroundColor Yellow
Write-Host $OverviewFile
Write-Host ""