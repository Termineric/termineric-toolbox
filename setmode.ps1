param (
    [string]$ModeName
)

$modeScript = "C:\Project-List\termineric-toolbox\modes\$ModeName.ps1"

if (Test-Path $modeScript) {
    Write-Host "Starten van modus: $ModeName" -ForegroundColor Cyan
    & $modeScript
} else {
    Write-Host "Fout !! Modus '$ModeName' bestaat niet." -ForegroundColor Red
}
