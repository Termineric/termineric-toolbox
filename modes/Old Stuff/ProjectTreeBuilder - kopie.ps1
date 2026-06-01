Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the path to the Templates folder
$templatesPath = "C:\Project-List\Commen-Files\Basic Project map\Templates"

# Get all JSON files in the Templates folder
$jsonFiles = Get-ChildItem -Path $templatesPath -Filter "*.json" | Select-Object -ExpandProperty Name

# Default JSON file
$defaultJsonFile = "BasicProjectTree.json"

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Project Template"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Label for JSON file selection
$labelJson = New-Object System.Windows.Forms.Label
$labelJson.Text = "Select a JSON Template:"
$labelJson.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelJson)

# Dropdown (ComboBox) for selecting the JSON template file
$comboBoxJson = New-Object System.Windows.Forms.ComboBox
$comboBoxJson.Location = New-Object System.Drawing.Point(150, 20)
$comboBoxJson.Width = 200
$comboBoxJson.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBoxJson.Items.AddRange($jsonFiles)
$comboBoxJson.SelectedItem = $defaultJsonFile  # Set default selected item
$form.Controls.Add($comboBoxJson)

# Label for target directory
$labelTarget = New-Object System.Windows.Forms.Label
$labelTarget.Text = "Target Root Directory:"
$labelTarget.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelTarget)

# Textbox for entering the target directory
$textBoxTarget = New-Object System.Windows.Forms.TextBox
$textBoxTarget.Location = New-Object System.Drawing.Point(150, 60)
$textBoxTarget.Width = 200
$form.Controls.Add($textBoxTarget)

# Button to start the project tree creation
$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Text = "Create Project Tree"
$buttonCreate.Location = New-Object System.Drawing.Point(150, 100)
$form.Controls.Add($buttonCreate)

# Event handler for the Create button click
$buttonCreate.Add_Click({
    $selectedJsonFile = $comboBoxJson.SelectedItem
    $targetRoot = $textBoxTarget.Text

    if ([string]::IsNullOrWhiteSpace($targetRoot)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a target root directory.")
        return
    }

    # Full path to the selected JSON file
    $jsonFilePath = Join-Path -Path $templatesPath -ChildPath $selectedJsonFile

    # Check if the JSON file exists
    if (!(Test-Path -Path $jsonFilePath)) {
        [System.Windows.Forms.MessageBox]::Show("JSON file not found.")
        return
    }

    # Read and parse the JSON file content
    $jsonData = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

    # Create the target root directory if it doesn't exist
    if (!(Test-Path -Path $targetRoot)) {
        New-Item -ItemType Directory -Path $targetRoot | Out-Null
    }

    # Function to decode Base64 content and write to a file
    function Write-FileContent {
        param (
            [string]$filePath,
            [string]$base64Content
        )
        if ($base64Content -eq "") {
            # Create an empty file if content is empty
            New-Item -ItemType File -Path $filePath -Force | Out-Null
        } else {
            # Decode the Base64 content and write to file
            $bytes = [System.Convert]::FromBase64String($base64Content)
            [System.IO.File]::WriteAllBytes($filePath, $bytes)
        }
    }

    # Function to recursively create the directory and file structure
    function Create-StructureFromJson {
        param (
            [array]$jsonData,
            [string]$parentPath
        )

        foreach ($item in $jsonData) {
            $itemPath = Join-Path -Path $parentPath -ChildPath $item.name

            if ($item.type -eq "folder") {
                # Create the directory if it is a folder
                New-Item -ItemType Directory -Path $itemPath -Force | Out-Null

                # Recursively create children items
                if ($item.children.Count -gt 0) {
                    Create-StructureFromJson -jsonData $item.children -parentPath $itemPath
                }
            } else {
                # Create or write to the file if it is a file
                Write-FileContent -filePath $itemPath -base64Content $item.content
            }
        }
    }

    # Start creating the structure from the JSON data
    Create-StructureFromJson -jsonData $jsonData -parentPath $targetRoot

    [System.Windows.Forms.MessageBox]::Show("Project structure has been successfully recreated at $targetRoot")
    $form.Close()
})

# Show the form
$form.ShowDialog()
