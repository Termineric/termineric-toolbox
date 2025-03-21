@echo off
SET BASE_DIR=C:\Project-List

:: Vraag om projectnaam
set /p PROJECT_NAME=Voer de projectnaam in: 
set /p PROJECT_VERSION=Voer de projectversie in: 

:: Vraag of het een Delphi-app is
echo Is dit een Delphi-app? (y/n)
set /p IS_DELPHI=

:: Vraag of het een website is
echo Is dit een websiteproject? (y/n)
set /p IS_WEB=

:: Maak de projectmap
set PROJECT_DIR=%BASE_DIR%\%PROJECT_NAME%
mkdir "%PROJECT_DIR%"

:: Standaard folders aanmaken
mkdir "%PROJECT_DIR%\Apps-Help"
mkdir "%PROJECT_DIR%\Commen Project Files"
mkdir "%PROJECT_DIR%\DataBase Scripts"
mkdir "%PROJECT_DIR%\Documents"
mkdir "%PROJECT_DIR%\Graphical"
mkdir "%PROJECT_DIR%\Hardware"
mkdir "%PROJECT_DIR%\Legacy Folder"
mkdir "%PROJECT_DIR%\LibrarySupport"
mkdir "%PROJECT_DIR%\Proof of concept"
mkdir "%PROJECT_DIR%\Settings-Info"
mkdir "%PROJECT_DIR%\Source-SandBox"

:: Submappen voor DataBase Scripts
mkdir "%PROJECT_DIR%\DataBase Scripts\JSON-Files"
mkdir "%PROJECT_DIR%\DataBase Scripts\SQL-Files"
mkdir "%PROJECT_DIR%\DataBase Scripts\XML-Files"

:: Submappen voor Graphical
mkdir "%PROJECT_DIR%\Graphical\Adobe Files"
mkdir "%PROJECT_DIR%\Graphical\Buttons"
mkdir "%PROJECT_DIR%\Graphical\General"
mkdir "%PROJECT_DIR%\Graphical\Icon"
mkdir "%PROJECT_DIR%\Graphical\Logo"
mkdir "%PROJECT_DIR%\Graphical\Style"

:: Submappen voor Proof of Concept
mkdir "%PROJECT_DIR%\Proof of concept\Sand-Box"

:: Als het een Delphi-app is, voeg de specifieke mappen toe
if /I "%IS_DELPHI%"=="y" (
    mkdir "%PROJECT_DIR%\Beta Version"
    mkdir "%PROJECT_DIR%\Current Version"
    mkdir "%PROJECT_DIR%\Source-%PROJECT_NAME%-%PROJECT_VERSION%"
    mkdir "%PROJECT_DIR%\Beta Version\All others stuff"
    mkdir "%PROJECT_DIR%\Beta Version\Apps-Help"
    mkdir "%PROJECT_DIR%\Beta Version\Apps-Help\Images"
    mkdir "%PROJECT_DIR%\Beta Version\DataBase"
    mkdir "%PROJECT_DIR%\Beta Version\DataBase\MetaData"
    mkdir "%PROJECT_DIR%\Beta Version\File Base"
    mkdir "%PROJECT_DIR%\Beta Version\Legacy Folder"
    mkdir "%PROJECT_DIR%\Beta Version\Log"
    mkdir "%PROJECT_DIR%\Beta Version\Reports"
    mkdir "%PROJECT_DIR%\Beta Version\Temps"
    echo. > "%PROJECT_DIR%\Beta Version\Dummy.File"
    echo. > "%PROJECT_DIR%\Current Version\Dummy.File"
)

:: Als het een websiteproject is, voeg de specifieke mappen toe
if /I "%IS_WEB%"=="y" (
    mkdir "%PROJECT_DIR%\Source-Web"
    echo. > "%PROJECT_DIR%\Source-Web\Dummy.File"
)

:: Voeg dummy bestanden toe zodat lege mappen niet verdwijnen
echo. > "%PROJECT_DIR%\Apps-Help\Dummy.File"
echo. > "%PROJECT_DIR%\Commen Project Files\Dummy.File"
echo. > "%PROJECT_DIR%\DataBase Scripts\Dummy.File"
echo. > "%PROJECT_DIR%\DataBase Scripts\JSON-Files\Dummy.File"
echo. > "%PROJECT_DIR%\DataBase Scripts\SQL-Files\Dummy.File"
echo. > "%PROJECT_DIR%\DataBase Scripts\XML-Files\Dummy.File"
echo. > "%PROJECT_DIR%\Documents\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Adobe Files\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Buttons\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\General\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Icon\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Logo\Dummy.File"
echo. > "%PROJECT_DIR%\Graphical\Style\Dummy.File"
echo. > "%PROJECT_DIR%\Hardware\Dummy.File"
echo. > "%PROJECT_DIR%\Legacy Folder\Dummy.File"
echo. > "%PROJECT_DIR%\LibrarySupport\Dummy.File"
echo. > "%PROJECT_DIR%\Proof of concept\Dummy.File"
echo. > "%PROJECT_DIR%\Proof of concept\Sand-Box\Dummy.File"
echo. > "%PROJECT_DIR%\Settings-Info\Dummy.File"
echo. > "%PROJECT_DIR%\Source-SandBox\Dummy.File"

:: Notificatie dat het project is aangemaakt
echo Project %PROJECT_NAME% versie %PROJECT_VERSION% is aangemaakt in %PROJECT_DIR%
pause
exit