# LaravelTableImporter - Handleiding

**Versie:** 1.0  
**Auteur:** TerminEric  
**Project:** Termineric Toolbox  

---

## ✨ Doel
`LaravelTableImporter.php` is een command-line tool waarmee je bestaande MySQL-tabellen kunt omzetten naar Laravel-conforme **migratie- en seederbestanden**.

De tool is onderdeel van de **Termineric Toolbox**, maar werkt direct in elk Laravel-project. Output wordt geplaatst in de map:
```
[project]/database/LaravelTableImporter/
```

---

## ⚡ Benodigdheden
- PHP 8.1+ met mysqli-extensie
- Laravel-project met geldige `database`-map
- `.env2` bestand in de **projectmap** (niet in de toolmap!) met o.a.:

```env
DB_HOST=localhost
DB_DATABASE=project_db
DB_USERNAME=root
DB_PASSWORD=secret
```

---

## 🔧 Installatie / Setup
1. Zet `LaravelTableImporter.php` in:
   ```
   C:\Project-List\termineric-toolbox\laravel\LaravelTableImporter\LaravelTableImporter.php
   ```

2. Voeg een PowerShell functie toe aan je profiel:
   ```powershell
   function tableimport {
       php "C:\Project-List\termineric-toolbox\laravel\LaravelTableImporter\LaravelTableImporter.php" $args
   }
   ```
   Sla dit op in `$PROFILE` zodat het automatisch geladen wordt.

3. Zorg dat `.env2` in de map staat van waaruit je werkt:
   ```
   C:\Project-List\MyLaravelProject\.env2
   ```

---

## ⚖️ Gebruik
Ga in de root van een Laravel-project staan (waar `.env2` staat) en voer uit:
```powershell
tableimport <tabelnaam>
```

Bijvoorbeeld:
```powershell
tableimport ZND_FILEREPOSITORY
```

De tool genereert:
- Migratiebestand in `database/LaravelTableImporter/migrations/`
- Seederbestand in `database/LaravelTableImporter/seeders/`
- Logbestand in `database/LaravelTableImporter/ImportTables.log`

---

## 📊 Logboek
Tijdens het importproces wordt elke stap gelogd naar:
```
[project]/database/LaravelTableImporter/ImportTables.log
```
Zowel successen als tussenstappen worden gelogd. Dit is handig bij fouten of crashes.

Voorbeeld:
```
[2025-03-21 17:00:00] start import: ZND_FILEREPOSITORY
[2025-03-21 17:00:00] database connection OK
[2025-03-21 17:00:00] fetching CREATE TABLE for ZND_FILEREPOSITORY
[2025-03-21 17:00:00] migration written: 2025_03_21_170000_create_znd_filerepository_table.php
[2025-03-21 17:00:00] seeder written: ZND_FILEREPOSITORYSeeder.php
```

---

## 💡 Tips
- Je kunt meerdere tabellen achter elkaar importeren:
  ```powershell
  tableimport klanten
  tableimport producten
  ```

- Combineer met Git voor versiebeheer op gegenereerde bestanden

- Nog geen support voor relaties of foreign keys (in ontwikkeling)

---

## 📹 Toekomstige uitbreidingen (roadmap)
- Slimmere field parsing (`nullable`, `default`, `unique`, enz.)
- `--preview` optie zonder schrijven
- Automatisch model genereren
- CLI-vlaggen voor configuratie

---

**Laatste update:** 21 maart 2025
