# GitUpdate.ps1 - Automatically detect project root and update Git

# Get the current directory where the script is executed
$currentPath = Get-Location

# Define the base project directory (all projects are under C:\Project-List)
$baseDir = "C:\Project-List"

# Properly escape the backslashes in $baseDir for regex
$baseDirEscaped = [regex]::Escape($baseDir)

# Ensure we are inside C:\Project-List\ (prevent running outside project scope)
if ($currentPath.Path -notmatch "^$baseDirEscaped\\") {
    Write-Host "❌ Error: You must run this script inside a project under $baseDir" -ForegroundColor Red
    exit 1
}

# Find the nearest project root (first folder under C:\Project-List\)
$relativePath = $currentPath.Path -replace "^$baseDirEscaped\\", ""
$projectRoot = "$baseDir\" + ($relativePath -split '\\')[0]

# Check if Git is initialized in the detected project root
if (-Not (Test-Path "$projectRoot\.git")) {
    Write-Host "❌ No Git repository found in $projectRoot" -ForegroundColor Red
    exit 1
}

# Navigate to the project root
Set-Location -Path $projectRoot

# Ask for a commit message
$commitMessage = Read-Host "Enter commit message"

# Run Git commands
git add .
git commit -m "$commitMessage"
git push origin main

Write-Host "✅ Git update completed successfully in $projectRoot" -ForegroundColor Green
