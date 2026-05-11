# Probeer alle bekende namen (met en zonder spatie/hoofdletter)
foreach ($name in @('ollama', 'Ollama', 'ollama app')) {
    Stop-Process -Name $name -Force -ErrorAction SilentlyContinue
}

# Eventueel, als je zeker wilt zijn, kill alle met 'olla' in de naam:
Get-Process | Where-Object { $_.ProcessName -like "*olla*" } | Stop-Process -Force -ErrorAction SilentlyContinue
