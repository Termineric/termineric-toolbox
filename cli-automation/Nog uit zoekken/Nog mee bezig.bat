@echo off
SET PROJECT_PATH=%CD%\Documents
if not exist "%PROJECT_PATH%" mkdir "%PROJECT_PATH%"

SET DOC_FILE=%PROJECT_PATH%\MartijnSoftware.txt
powershell -Command "(New-Object Net.WebClient).DownloadString('https://chatgpt.com/g/g-p-67c556a7848c81918be904ce8d57e9d5-martijn-software-uit-zoekken/project') | Out-File -Encoding UTF8 '%DOC_FILE%'"

echo Document opgeslagen in %DOC_FILE%
pause
