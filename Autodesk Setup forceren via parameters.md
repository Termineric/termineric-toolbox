 1. Autodesk Setup forceren via parameters
Veel Autodesk-setup-bestanden (zoals setup.exe) ondersteunen stille of geforceerde installatie via command-line:

❗ Probeer dit in PowerShell of CMD (in map waar setup.exe staat):
cmd
Kopiëren
Bewerken
setup.exe /S /INSTALL /FORCE
Of:

cmd
Kopiëren
Bewerken
setup.exe /quiet /norestart /force
🔍 Niet alle versies ondersteunen /force — het hangt af van de setup-engine (InstallShield vs. Autodesk Custom Installer). Als dit niks doet, zie optie 2.

🧨 2. Gebruik "Microsoft Install/Uninstall Troubleshooter"
Als je geen normale uninstall kunt doen en de installer blijft hangen, gebruik dan deze officiële tool van Microsoft:

👉 Download:
🔗 https://support.microsoft.com/fixit

Wat het doet:
Verwijdert kapotte installatievermeldingen uit het register

Verhelpt het probleem dat installatie zegt: "al aanwezig" of "niet volledig verwijderd"

💡 Tip: selecteer dan handmatig iets als "Revit 2022" of "Autodesk Licensing" als het programma het toont – of kies "Niet vermeld" en voer dan de exacte naam in.

🧹 3. Check Installer logs
Als de setup crasht of blokkeert:

Check %LOCALAPPDATA%\Autodesk\ODIS\ voor installatielogs (bijv. Install.log)

Daarin kun je zien of er een specifieke fout of "conflict" is

→ Als je wil, kun je een logbestand uploaden en ik help je de foutregel eruit te halen.

🔧 4. Register handmatig opschonen laatste resten
Als echt niets helpt:

Open regedit

Zoek naar:

Revit 2022

Autodesk

Autodesk Installer

GUID’s in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

Verwijder alleen sleutels die verwijzen naar foutieve installaties (bijvoorbeeld incomplete Revit 2022-installatie).