@echo off
SET BASE_DIR=C:\Project-List
SET PROJECT_MGMT_DIR=%BASE_DIR%\Project-Beheer
SET BACKUP_DIR=%PROJECT_MGMT_DIR%\Backups
SET CLEANUP_DIR=%PROJECT_MGMT_DIR%\Cleanup
SET LOG_DIR=%PROJECT_MGMT_DIR%\Logs

:: Maak directories aan als ze niet bestaan
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
if not exist "%CLEANUP_DIR%" mkdir "%CLEANUP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Controleer argumenten
if "%1"=="cleanup" goto cleanup
if "%1"=="archive" goto archive
if "%1"=="gitstatus" goto gitstatus
if "%1"=="initialize" goto initialize
if "%1"=="tree" goto generate_tree
if "%1"=="document" goto save_document

:: Menu
:menu
cls
echo ================================
echo    Project Beheer Tools
echo ================================

echo 1. Project Cleanup Tool
echo 2. ZIP Archiver voor Projecten
echo 3. Git Status Checker
echo 4. Project Initializer
echo 5. Genereer projectstructuur file
echo 6. Document opslaan
echo 7. Exit

set /p choice=Maak een keuze: 
if "%choice%"=="1" goto cleanup
if "%choice%"=="2" goto archive
if "%choice%"=="3" goto gitstatus
if "%choice%"=="4" goto initialize
if "%choice%"=="5" goto generate_tree
if "%choice%"=="6" goto save_document
if "%choice%"=="7" exit

goto menu

:cleanup
:: Project Cleanup Tool - Verwijdert tijdelijke bestanden
set PROJECT_PATH=%CD%
if not "%2"=="" set PROJECT_PATH=%2

if not exist "%PROJECT_PATH%" (
    echo Fout: Projectmap "%PROJECT_PATH%" bestaat niet.
    pause
    exit
)

echo [%DATE% %TIME%] Cleaning up "%PROJECT_PATH%" >> "%LOG_DIR%\cleanup.log"

for /r "%PROJECT_PATH%" %%F in (*.tmp) do del "%%F"
for /r "%PROJECT_PATH%" %%F in (*.log) do del "%%F"
for /r "%PROJECT_PATH%" %%F in (*.bak) do del "%%F"

echo Cleanup voltooid.
pause
exit

:archive
:: ZIP Archiver
set PROJECT_PATH=%CD%
if not "%2"=="" set PROJECT_PATH=%2

if not exist "%PROJECT_PATH%" (
    echo Fout: Projectmap "%PROJECT_PATH%" bestaat niet.
    pause
    exit
)

set ZIP_FILE=%BACKUP_DIR%\%~nx1_%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%.zip

powershell -command "Compress-Archive -Path '%PROJECT_PATH%' -DestinationPath '%ZIP_FILE%' -Force"

echo Archief opgeslagen als %ZIP_FILE%
pause
exit

:gitstatus
:: Git Status Checker
set ORIGINAL_PATH=%CD%
if not exist "%PROJECT_MGMT_DIR%\Backup2Git_config.CFG" (
    echo Fout: Configuratiebestand ontbreekt.
    pause
    exit
)

for /f "delims=" %%D in (%PROJECT_MGMT_DIR%\Backup2Git_config.CFG) do (
    if exist "%%D\.git" (
        echo --- Status voor %%D ---
        cd "%%D"
        git status
        echo -------------------------
    ) else (
        echo Geen Git-repository gevonden in %%D
    )
)

cd "%ORIGINAL_PATH%"
pause
exit

:initialize
:: Project Initializer
set /p PROJECT_NAME=Voer de projectnaam in: 
set /p PROJECT_TYPE=Is het een (D)elphi of (W)eb project?: 

set PROJECT_PATH=%BASE_DIR%\%PROJECT_NAME%
if exist "%PROJECT_PATH%" (
    echo Fout: Project "%PROJECT_NAME%" bestaat al.
    pause
    exit
)

mkdir "%PROJECT_PATH%"
if /I "%PROJECT_TYPE%"=="D" mkdir "%PROJECT_PATH%\Source-%PROJECT_NAME%"
if /I "%PROJECT_TYPE%"=="W" mkdir "%PROJECT_PATH%\Source-Web"

echo Project %PROJECT_NAME% aangemaakt.
pause
exit

:generate_tree
:: Genereert een projectstructuur in de huidige map
set TREE_FILE=%CD%\structuur.txt
if not exist "%CD%" (
    echo Fout: Huidige map bestaat niet.
    pause
    exit
)

echo [%DATE% %TIME%] Generating project structure in "%CD%" >> "%LOG_DIR%\tree.log"
tree "%CD%" /F /A > "%TREE_FILE%"
echo Projectstructuur opgeslagen in "%TREE_FILE%"
pause
exit

:save_document
:: Document opslaan in de huidige projectmap
set DOC_PATH=%CD%\Documents
if not exist "%DOC_PATH%" mkdir "%DOC_PATH%"

set /p DOC_NAME=Voer de bestandsnaam in (zonder extensie): 
set DOC_FILE=%DOC_PATH%\%DOC_NAME%.txt

:: Vraagt om inhoud van het document
echo Typ de inhoud van het document. Druk op Ctrl+Z en Enter om op te slaan.
copy con "%DOC_FILE%"
echo Document opgeslagen als "%DOC_FILE%"
pause
exit
