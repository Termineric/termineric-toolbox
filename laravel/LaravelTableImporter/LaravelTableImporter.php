<?php

/*
|--------------------------------------------------------------------------
| LaravelTableImporter.php – Roadmap / Featurelijst
|--------------------------------------------------------------------------
| Dit script is bedoeld als universele tool voor het omzetten van bestaande
| MySQL-tabellen naar Laravel-migraties en seeders. Hieronder een overzicht
| van gewenste (en deels gerealiseerde) functies.
|
| ✅ Seeder in batches genereren
| 🔄 Slimmere datatype-conversie (TINYINT → boolean, ENUM → enum, enz.)
| 🔄 Kolom parsing uitbreiden:
|     - datatype
|     - lengte
|     - nullable()
|     - default()
|     - primary(), unique()
| ⏳ Automatisch model genereren
| ⏳ CLI-opties (--truncate, --preview, --model)
| ⏳ Logging verbeteren (kleur, statusiconen, kort/uitgebreid)
| ⏳ Documentatie genereren per tabel (Markdown of .txt)
|
| ⚠️ Werk per stap. Test elke functie apart voordat je verdergaat.
|--------------------------------------------------------------------------
*/

$envFile = getcwd() . DIRECTORY_SEPARATOR . '.env2';
if (!file_exists($envFile)) {
    echo "❌ Configuratiebestand .env2 niet gevonden in: " . getcwd() . "\n";
    exit(1);
}

// Inladen van .env2
$lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line) {
    if (strpos(trim($line), '#') === 0) continue;
    putenv($line);
}

$host = getenv('DB_HOST');
$user = getenv('DB_USERNAME');
$pass = getenv('DB_PASSWORD');
$db   = getenv('DB_DATABASE');

$table = $argv[1] ?? null;

$logPath = getcwd() . DIRECTORY_SEPARATOR . "database" . DIRECTORY_SEPARATOR . "LaravelTableImporter";
if (!is_dir($logPath)) mkdir($logPath, 0777, true);
$logFile = $logPath . DIRECTORY_SEPARATOR . "ImportTables.log";
$logStart = "[" . date("Y-m-d H:i:s") . "] start import: {$table}\n";
file_put_contents($logFile, $logStart, FILE_APPEND);

if (!$table) {
    echo "❌ Geen tabelnaam opgegeven.\nGebruik: php LaravelTableImporter.php <tabelnaam>\n";
    exit(1);
}

// Verbinding maken
$mysqli = new mysqli($host, $user, $pass, $db);
file_put_contents($logFile, "[" . date("Y-m-d H:i:s") . "] database connection OK\n", FILE_APPEND);
if ($mysqli->connect_error) {
    die("❌ Connectie mislukt: " . $mysqli->connect_error . "\n");
}

// Tabelstructuur ophalen
file_put_contents($logFile, "[" . date("Y-m-d H:i:s") . "] fetching CREATE TABLE for {$table}\n", FILE_APPEND);
$res = $mysqli->query("SHOW CREATE TABLE `{$table}`");
if (!$res || $res->num_rows == 0) {
    die("❌ Tabel '{$table}' niet gevonden in database.\n");
}
$row = $res->fetch_assoc();
$createSQL = $row['Create Table'] ?? array_values($row)[1];

// Migratiebestand genereren
$datePrefix = date("Y_m_d_His");
$migrationFile = "{$datePrefix}_create_" . strtolower($table) . "_table.php";
$migrationPath = getcwd() . DIRECTORY_SEPARATOR . "database" . DIRECTORY_SEPARATOR . "LaravelTableImporter" . DIRECTORY_SEPARATOR . "migrations" . DIRECTORY_SEPARATOR;
if (!is_dir($migrationPath)) mkdir($migrationPath, 0777, true);

// Zeer basale parser – voorbeeldregel: `id` int(11) NOT NULL AUTO_INCREMENT,
preg_match_all('/`([^`]*)`\s+([^\s,]+)/', $createSQL, $matches, PREG_SET_ORDER);
$fields = [];
foreach ($matches as $match) {
    $name = $match[1];
    $type = strtolower($match[2]);
    if (str_starts_with($type, 'int')) $line = "\$table->integer('{$name}');";
    elseif (str_starts_with($type, 'varchar')) $line = "\$table->string('{$name}');";
    elseif (str_starts_with($type, 'text')) $line = "\$table->text('{$name}');";
    elseif (str_starts_with($type, 'datetime')) $line = "\$table->dateTime('{$name}');";
    else $line = "\$table->string('{$name}'); // onbekend type: {$type}";
    $fields[] = "            " . $line;
}

$migrationContent = "<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('{$table}', function (Blueprint \$table) {
" . implode("\n", $fields) . "
        });
    }

    public function down() {
        Schema::dropIfExists('{$table}');
    }
};
";

file_put_contents($migrationPath . $migrationFile, $migrationContent);
file_put_contents($logFile, "[" . date("Y-m-d H:i:s") . "] migration written: {$migrationFile}\n", FILE_APPEND);
echo "✅ Migratiebestand gegenereerd: output/migrations/{$migrationFile}\n";

// Seeder genereren (eenvoudig, met batching)
$seedPath = getcwd() . DIRECTORY_SEPARATOR . "database" . DIRECTORY_SEPARATOR . "LaravelTableImporter" . DIRECTORY_SEPARATOR . "seeders" . DIRECTORY_SEPARATOR;
if (!is_dir($seedPath)) mkdir($seedPath, 0777, true);
$seedFile = ucfirst($table) . "Seeder.php";

$data = $mysqli->query("SELECT * FROM `{$table}`");
$rows = [];
while ($r = $data->fetch_assoc()) $rows[] = $r;

$chunks = array_chunk($rows, 100);
$inserts = "";
foreach ($chunks as $chunk) {
    $inserts .= "        DB::table('{$table}')->insert([\n";
    foreach ($chunk as $row) {
        $rowStr = var_export($row, true);
        $rowStr = preg_replace("/(\s+)array \(/", '[', $rowStr);
        $rowStr = preg_replace("/\),/", '],', $rowStr);
        $rowStr = preg_replace("/\)$/", ']', $rowStr);
        $rowStr = str_replace("=>", " =>", $rowStr);
        $inserts .= "            {$rowStr},\n";
    }
    $inserts .= "        ]);\n\n";
}

$seederContent = "<?php

use Illuminate\\Database\\Seeder;
use Illuminate\\Support\\Facades\\DB;

class {$table}Seeder extends Seeder {
    public function run() {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('{$table}')->truncate();
{$inserts}    }
}
";

file_put_contents($seedPath . $seedFile, $seederContent);
file_put_contents($logFile, "[" . date("Y-m-d H:i:s") . "] seeder written: {$seedFile}\n", FILE_APPEND);
echo "✅ Seederbestand gegenereerd: output/seeders/{$seedFile}\n";
