# 🧰 Laravel Tools – Termineric Toolbox

This folder contains tools and helper scripts related to Laravel development.

These are not Laravel projects themselves, but **external utilities** designed to work *with* Laravel applications — especially in situations where you are dealing with:

- Legacy databases or inconsistent schemas
- Data migration from older systems
- Custom import/export workflows
- Development automation

---

## 🧭 Project Focus
I created these tools to assist with specific needs that often fall outside the scope of a typical Laravel app. Most of them were built while working on legacy systems that had:

- No proper database migrations
- No seeder structures
- Mixed naming conventions
- Missing documentation

Rather than rewriting everything by hand, I wanted reusable tooling that could convert existing structures to modern Laravel standards.

---

## 📦 Tools Included

### ✅ LaravelTableImporter.php
This command-line tool connects to a MySQL/MariaDB database, inspects an existing table, and generates:

- A Laravel-compatible **migration file**
- A **seeder file** with real data
- Logs of the process (to help trace issues)

It is useful when working with old tables that need to be brought into a clean Laravel codebase.

See [`LaravelTableImporter/README.md`](LaravelTableImporter/README.md) for usage instructions.

---

## 🚧 In Development
This folder will grow to include more tooling, such as:

- Model generation from database structure
- Field inspection helpers
- Artisan extensions for setup/imports
- Schema documentation scripts

Most tools are written in standalone PHP and designed to run from the command line.

---

**Maintained by:** TerminEric  
**Status:** Actively evolving — tools may be unstable while I work on them.

Feedback welcome!
