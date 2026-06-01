# Enable Windows Forms for GUI
Add-Type -AssemblyName System.Windows.Forms

# Select Folder for Target Directory if Not Provided
function Select-Folder {
    param (
        [string]$initialDirectory = "."
    )
    
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.SelectedPath = (Get-Location).Path
    $folderBrowser.Description = "Select a target folder to build the project structure"
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("No target folder selected. Exiting...", "Operation Canceled", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        exit
    }
}

param (
    [string]$targetFolder = "",
    [string]$jsonTemplate = ""
)

# Validate JSON Template Parameter
$templateDir = Join-Path -Path $PSScriptRoot -ChildPath "templates"
if (-not $jsonTemplate) {
    $jsonTemplate = [System.Windows.Forms.MessageBox]::Show("No JSON template provided. Select a template file from the 'templates' directory.")
    exit
}

$jsonFilePath = Join-Path -Path $templateDir -ChildPath $jsonTemplate
if (!(Test-Path -Path $jsonFilePath)) {
    [System.Windows.Forms.MessageBox]::Show("JSON template file not found. Please check the path and try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Validate or Select Target Folder
if (-not (Test-Path -Path $targetFolder -PathType Container)) {
    $targetFolder = Select-Folder
}

# Function to build folder structure from JSON data
function Build-FolderStructure {
    param (
        [PSCustomObject]$structure,
        [string]$currentPath
    )

    foreach ($item in $structure) {
        $itemPath = Join-Path -Path $currentPath -ChildPath $item.name

        if ($item.type -eq "folder") {
            New-Item -ItemType Directory -Path $itemPath -Force | Out-Null
            Build-FolderStructure -structure $item.children -currentPath $itemPath
        } elseif ($item.type -eq "file") {
            if ($item.name -ne "Dummy.File") {
                $bytes = [Convert]::FromBase64String($item.content)
                [System.IO.File]::WriteAllBytes($itemPath, $bytes)
            } else {
                New-Item -ItemType File -Path $itemPath -Force | Out-Null
            }
        }
    }
}

# Read JSON and Build Folder Structure
$jsonData = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
Build-FolderStructure -structure $jsonData -currentPath $targetFolder

[System.Windows.Forms.MessageBox]::Show("Project structure built successfully in: $targetFolder", "Build Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
