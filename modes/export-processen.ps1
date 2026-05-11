$outputFile = Join-Path $PSScriptRoot "processen-lijst.txt"

Get-Process |
    Sort-Object ProcessName |
    Select-Object Id, ProcessName, MainWindowTitle, Path |
    Format-Table -Wrap -AutoSize |
    Out-String |
    Set-Content -Path $outputFile

Write-Host "Alle actieve processen geëxporteerd naar $outputFile (Path als laatste kolom)." -ForegroundColor Green
