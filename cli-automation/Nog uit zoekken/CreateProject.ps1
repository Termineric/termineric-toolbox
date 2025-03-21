# CreateProject.ps1 - Automates project setup with Delphi, Web, or Laravel options

# Set base directory for all projects
$BASE_DIR = "C:\Project-List"

# Ask for project name (no spaces allowed)
$PROJECT_NAME = Read-Host "Enter project name (no spaces)"
$PROJECT_NAME = $PROJECT_NAME -replace "\s", "-"  # Replace spaces with dashes

# Ask for project version
$PROJECT_VERSION = Read-Host "Enter project version"

# Choose project type
Write-Host "Choose project type:"
Write-Host "1 - Delphi"
Write-Host "2 - Web (Basic)"
Write-Host "3 - Laravel (Local Install)"
$PROJECT_TYPE = Read-Host "Enter choice (1/2/3)"

# Define the project root folder
$PROJECT_DIR = "$BASE_DIR\$PROJECT_NAME"

# Create main project folder
New-Item -ItemType Directory -Path $PROJECT_DIR -Force

# Common folders (Always included in every project)
$commonFolders = @(
    "Apps-Help", "Documents", "Graphical",
    "LibrarySupport", "Settings-Info"
)

# Create common folders
foreach ($folder in $commonFolders) {
    New-Item -ItemType Directory -Path "$PROJECT_DIR\$folder" -Force
    New-Item -ItemType File -Path "$PROJECT_DIR\$folder\Dummy.File" -Force | Out-Null
}

# If Delphi project, create Delphi-specific folders
if ($PROJECT_TYPE -eq "1") {
    $delphiFolders = @(
        "Beta Version", "Current Version",
        "Source-$PROJECT_NAME-$PROJECT_VERSION",
        "Beta Version\All others stuff", "Beta Version\Apps-Help",
        "Beta Version\Apps-Help\Images", "Beta Version\DataBase",
        "Beta Version\DataBase\MetaData", "Beta Version\File Base",
        "Beta Version\Legacy Folder", "Beta Version\Log",
        "Beta Version\Reports", "Beta Version\Temps"
    )

    foreach ($folder in $delphiFolders) {
        New-Item -ItemType Directory -Path "$PROJECT_DIR\$folder" -Force
        New-Item -ItemType File -Path "$PROJECT_DIR\$folder\Dummy.File" -Force | Out-Null
    }
    Write-Host "Delphi project structure created!"
}

# If Web project, create a basic Web folder with Source-Web
if ($PROJECT_TYPE -eq "2") {
    $WEB_DIR = "$PROJECT_DIR\Source-Web"
    New-Item -ItemType Directory -Path $WEB_DIR -Force

    # Extra folders needed for web projects
    $webExtraFolders = @(
        "Source-Web\assets",
        "Source-Web\css",
        "Source-Web\js"
    )

    foreach ($folder in $webExtraFolders) {
        New-Item -ItemType Directory -Path "$PROJECT_DIR\$folder" -Force
        New-Item -ItemType File -Path "$PROJECT_DIR\$folder\Dummy.File" -Force | Out-Null
    }

    New-Item -ItemType File -Path "$WEB_DIR\index.html" -Force | Out-Null
    Write-Host "Web project structure created!"
}

# If Laravel project, install Laravel locally in Project-Source
if ($PROJECT_TYPE -eq "3") {
    $LARAVEL_DIR = "$PROJECT_DIR\Project-Source"
    New-Item -ItemType Directory -Path $LARAVEL_DIR -Force

    Write-Host "Installing Laravel locally in $LARAVEL_DIR ..."

    Set-Location -Path $LARAVEL_DIR

    # Check if Composer exists globally
    $composerCmd = "composer"
    if (-Not (Get-Command "composer" -ErrorAction SilentlyContinue)) {
        Write-Host "Composer not found globally, installing local Composer..."
        Invoke-WebRequest -Uri "https://getcomposer.org/installer" -OutFile "composer-setup.php"
        php composer-setup.php --install-dir=$LARAVEL_DIR --filename=composer.phar
        Remove-Item "composer-setup.php"
        $composerCmd = "php composer.phar"
    }

    # Download Laravel locally without global installation
    Write-Host "Downloading Laravel..."
    & $composerCmd create-project laravel/laravel . --no-interaction --no-install

    # Install dependencies locally
    Write-Host "Installing Laravel dependencies..."
    & $composerCmd install

    # Generate app key
    Write-Host "Generating Laravel app key..."
    php artisan key:generate

    Write-Host "Laravel project (Local) created in $LARAVEL_DIR!"
}

# Final notification
Write-Host "Project $PROJECT_NAME version $PROJECT_VERSION created at $PROJECT_DIR"
