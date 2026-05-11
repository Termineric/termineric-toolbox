# 🧰 GTP Kennis-doc (Termineric Toolbox)

📌 **Doel:** Dit document bevat alle kennis over de toolchain en scripts die ik heb ontwikkeld om Laravel-projecten te ondersteunen. De nadruk ligt op automatisering, import/export en command-line tools.

---

## 🔧 LaravelTableImporter

- Pad: `C:/Project-List/termineric-toolbox/laravel/LaravelTableImporter/LaravelTableImporter.php`
- Doel: Zet bestaande tabellen om naar Laravel-conforme migraties en seeders
- Input: `.env2` bestand met databaseconfiguratie
- Output:
  - Migraties in: `[getcwd()]/database/migrations/`
  - Seeders in: `[getcwd()]/database/seeders/`
  - Logbestand: `database/LaravelTableImporter/ImportTables.log`
- Herkent automatisch: datatype, lengte, nullable, default, primary, unique
- Werkt buiten Laravel om via CMD-alias

---

## 🛠 ExportTableToSeeder (Artisan Command)

- Pad: `app/Console/Commands/ExportTableToSeeder.php`
- Gebruik: `php artisan export:table {table} {--with-id}`
- Output in `database/seeders/export/`
- Zorgt voor snelle back-up van tabelinhoud als PHP array
- Houdt rekening met datumvelden (`created_at`, `updated_at`)

---

## ⚙️ CMD / CLI Tooling

- Windows: CMD-alias gemaakt om LaravelTableImporter universeel aan te roepen
- Project-mapstructuur: alles onder `C:/Project-List`
- Standaardprojectstructuur: Beta Version, Source-Appname, Graphical, DataBase Scripts, enz.

---

📄 Dit document is op 2025-04-04 aangemaakt.  
📅 Laatst bijgewerkt op 2025-04-04
