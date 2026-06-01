# {ARGUMENTS}
param (
    [Parameter(Position = 0)]
    [string]$ProjectName = "",

    [Alias("t")]
    [string]$Template = "Default"
)

# {CONFIG}
$ToolboxRoot = "C:\Project-List\termineric-toolbox\modes"
$TemplateRoot = Join-Path $ToolboxRoot "templates"

# {TEMPLATE:NORMALIZE}
if (-not $Template.ToLower().EndsWith(".json")) {
    $Template = "$Template.json"
}

$TemplatePath = Join-Path $TemplateRoot $Template

# {TEMPLATE:VALIDATE}
if (-not (Test-Path $TemplatePath)) {
    Write-Host ""
    Write-Host "[ERROR] Template not found:"
    Write-Host $TemplatePath
    Write-Host ""
    exit 1
}

# {PROJECT:TARGET}
$CurrentPath = (Get-Location).Path

if ([string]::IsNullOrWhiteSpace($ProjectName)) {

    $ProjectPath = $CurrentPath
    $ProjectName = Split-Path $ProjectPath -Leaf

} else {

    $ProjectPath = Join-Path $CurrentPath $ProjectName

    if (-not (Test-Path $ProjectPath)) {
        New-Item -ItemType Directory -Path $ProjectPath | Out-Null
        Write-Host "[OK] Project folder created: $ProjectName"
    } else {
        Write-Host "[EXISTS] Project folder: $ProjectName"
    }
}

# {BUILD}
function Build-Structure {
    param (
        [object[]]$Items,
        [string]$BasePath
    )

    foreach ($Item in $Items) {

        $ItemPath = Join-Path $BasePath $Item.name

        if ($Item.type -eq "folder") {

            if (-not (Test-Path $ItemPath)) {
                New-Item -ItemType Directory -Path $ItemPath -Force | Out-Null
                Write-Host "[OK] Folder: $ItemPath"
            } else {
                Write-Host "[EXISTS] Folder: $ItemPath"
            }

            if ($Item.children) {
                Build-Structure -Items $Item.children -BasePath $ItemPath
            }
        }

        elseif ($Item.type -eq "file") {

            if (-not (Test-Path $ItemPath)) {
                New-Item -ItemType File -Path $ItemPath -Force | Out-Null
                Write-Host "[OK] File: $ItemPath"
            } else {
                Write-Host "[EXISTS] File: $ItemPath"
            }
        }

        else {
            Write-Host "[SKIP] Unknown type: $($Item.type) for $($Item.name)"
        }
    }
}

# {RUN}
$JsonData = Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "Project:  $ProjectName"
Write-Host "Path:     $ProjectPath"
Write-Host "Template: $TemplatePath"
Write-Host ""

Build-Structure -Items $JsonData -BasePath $ProjectPath

Write-Host ""
Write-Host "Project structure completed."
Write-Host ""