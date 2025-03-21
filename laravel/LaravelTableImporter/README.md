# LaravelTableImporter - User Guide

**Version:** 1.0  
**Author:** TerminEric  
**Project:** Termineric Toolbox  

---

## ✨ Purpose
`LaravelTableImporter.php` is a command-line tool that converts existing MySQL tables into Laravel-compliant **migration and seeder files**.

The tool is part of the **Termineric Toolbox**, but it works directly inside any Laravel project. Output is placed in:
```
[project]/database/LaravelTableImporter/
```

---

## ⚡ Requirements
- PHP 8.1+ with the mysqli extension
- Laravel project with a valid `database` directory
- `.env2` file located in the **project root** (not the tool folder), for example:

```env
DB_HOST=localhost
DB_DATABASE=project_db
DB_USERNAME=root
DB_PASSWORD=secret
```

---

## 🔧 Installation / Setup
1. Place `LaravelTableImporter.php` here:
   ```
   C:\Project-List\termineric-toolbox\laravel\LaravelTableImporter\LaravelTableImporter.php
   ```

2. Add a PowerShell function to your profile:
   ```powershell
   function tableimport {
       php "C:\Project-List\termineric-toolbox\laravel\LaravelTableImporter\LaravelTableImporter.php" $args
   }
   ```
   Save this in your `$PROFILE` so it loads automatically.

3. Make sure `.env2` exists in the root of the Laravel project you're working in:
   ```
   C:\Project-List\MyLaravelProject\.env2
   ```

---

## ⚖️ Usage
From the root of your Laravel project (where `.env2` exists), run:
```powershell
tableimport <table_name>
```

Example:
```powershell
tableimport your_table_name
```

The tool will generate:
- Migration file in `database/LaravelTableImporter/migrations/`
- Seeder file in `database/LaravelTableImporter/seeders/`
- Log file in `database/LaravelTableImporter/ImportTables.log`

---

## 📊 Logging
Each step of the process is logged to:
```
[project]/database/LaravelTableImporter/ImportTables.log
```
This includes all intermediate steps and success messages, useful for debugging crashes or reviewing the import.

Example:
```
[2025-03-21 17:00:00] start import: your_table_name
[2025-03-21 17:00:00] database connection OK
[2025-03-21 17:00:00] fetching CREATE TABLE for your_table_name
[2025-03-21 17:00:00] migration written: 2025_03_21_170000_create_your_table_name_table.php
[2025-03-21 17:00:00] seeder written: YourTableNameSeeder.php
```

---

## 💡 Tips
- You can import multiple tables in sequence:
  ```powershell
  tableimport users
  tableimport orders
  ```

- Combine with Git to version control generated files

- No support yet for relationships or foreign keys (in development)

---

## 📹 Planned Features (Roadmap)
- Smarter field parsing (`nullable`, `default`, `unique`, etc.)
- `--preview` option (generate without writing)
- Automatic model generation
- CLI flags for customization

---

**Last updated:** March 21, 2025
