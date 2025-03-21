# Define output file
$historyFilePath = "C:\Project-List\powershell_history.txt"

# Get current date and date from 3 days ago
$daysAgo = (Get-Date).AddDays(-3)

# PowerShell history file location
$psHistoryFile = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

# Check if history file exists
if (Test-Path $psHistoryFile) {
    # Extract history and prepend timestamps
    Get-Content $psHistoryFile | ForEach-Object {
        "$(Get-Date) [PS] $_"
    } | Out-File $historyFilePath
}

Write-Host "PowerShell command history saved to: $historyFilePath"
