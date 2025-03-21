@echo off
SET BASE_DIR=C:\Project-List
SET PROJECT_MGMT_DIR=%BASE_DIR%\Project-Beheer
SET CONFIG_FILE=%PROJECT_MGMT_DIR%\Backup2Git_config.CFG
SET LOG_DIR=%PROJECT_MGMT_DIR%\Logs
SET MAX_LOG_AGE=14

:: Maak de log-directory en project-beheer directory aan als deze niet bestaan
if not exist %PROJECT_MGMT_DIR% mkdir %PROJECT_MGMT_DIR%
if not exist %LOG_DIR% mkdir %LOG_DIR%

:: Start logging
echo [%DATE% %TIME%] Starting Git Auto-Backup >> %LOG_DIR%\global_backup.log

:: Controleer of config bestand bestaat
if not exist %CONFIG_FILE% (
    echo [%DATE% %TIME%] Configuratiebestand niet gevonden! Maak %CONFIG_FILE% met projectpaden. >> %LOG_DIR%\global_backup.log
    exit /b
)

:: Controleer of het een werkdag is (Maandag - Vrijdag)
for /f %%A in ('powershell -command "(Get-Date).DayOfWeek"') do set DAY=%%A
if "%DAY%"=="Saturday" goto skip_backup
if "%DAY%"=="Sunday" goto skip_backup

:: Lees projectpaden uit configuratiebestand
for /f "delims=" %%D in (%CONFIG_FILE%) do (
    if exist "%%D\.git" (
        set PROJECT_LOG=%LOG_DIR%\git_backup_%%~nxD.log
        cd "%%D"
        git status | findstr /C:"nothing to commit" > nul
        if errorlevel 1 (
            echo [%DATE% %TIME%] Wijzigingen gevonden in %%D, back-up starten >> %PROJECT_LOG%
            git add .
            git commit -m "Automatische backup: %DATE% %TIME%"
            git push origin main
            echo [%DATE% %TIME%] Backup completed for %%D >> %PROJECT_LOG%
        ) else (
            echo [%DATE% %TIME%] Geen wijzigingen in %%D, overslaan >> %PROJECT_LOG%
        )
    ) else (
        echo [%DATE% %TIME%] Git repo niet gevonden voor %%D >> %LOG_DIR%\global_backup.log
    )
)

echo [%DATE% %TIME%] Backup finished >> %LOG_DIR%\global_backup.log

:: Stuur een notificatie naar de gebruiker als er een back-up is gemaakt
findstr /C:"Backup completed" %LOG_DIR%\global_backup.log > nul
if errorlevel 1 (
    echo [%DATE% %TIME%] Geen back-ups uitgevoerd vandaag. >> %LOG_DIR%\global_backup.log
) else (
    powershell -command "[System.Windows.Forms.MessageBox]::Show('Git Auto-Backup voltooid!', 'Backup Notificatie', 'OK', 'Information')"
)

:: Beperk de logs tot de laatste 100 regels
(for /f "skip=100 delims=" %%A in ('type %LOG_DIR%\global_backup.log') do echo %%A) > %LOG_DIR%\global_backup_temp.log
move /Y %LOG_DIR%\global_backup_temp.log %LOG_DIR%\global_backup.log > nul

:: Opruimen van oude logs (ouder dan 14 dagen)
powershell -command "Get-ChildItem %LOG_DIR% -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) } | Remove-Item -Force"

exit

:skip_backup
echo [%DATE% %TIME%] Weekend - Geen automatische backup uitgevoerd. >> %LOG_DIR%\global_backup.log
exit
