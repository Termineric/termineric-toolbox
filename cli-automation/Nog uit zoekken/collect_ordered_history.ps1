# Define output file
$historyFilePath = "C:\Project-List\all_terminal_history.txt"

# Get current date and date from 3 days ago
$daysAgo = (Get-Date).AddDays(-3)

# Temporary files for storing history
$cmdFile = "cmd_history.txt"
$psFile = "powershell_history.txt"
$wslFile = "wsl_history.txt"
$mergedFile = "merged_history.txt"

# ---- CMD History (Current Session Only) ----
doskey /history | ForEach-Object { "$(Get-Date) [CMD] $_" } > $cmdFile

# ---- PowerShell History ----
$psHistoryFile = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $psHistoryFile) {
    Get-Content $psHistoryFile | ForEach-Object { "$(Get-Date) [PS] $_" } > $psFile
}

# ---- WSL (Bash) History ----
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash -c "HISTTIMEFORMAT='%F %T ' history" | awk '{print $1, $2, "[WSL]", substr($0, index($0,$3))}' > $wslFile
}

# ---- Merge All Histories ----
Get-Content $cmdFile, $psFile, $wslFile | Sort-Object { $_ -match '\[(CMD|PS|WSL)\]'; [datetime]::Parse($_.Substring(0, 19)) } | Out-File $mergedFile

# Move final file to project folder
Move-Item -Force $mergedFile $historyFilePath

# ---- Cleanup Temporary Files ----
Remove-Item $cmdFile, $psFile, $wslFile -ErrorAction SilentlyContinue

Write-Host "Command history saved in order to: $historyFilePath"
