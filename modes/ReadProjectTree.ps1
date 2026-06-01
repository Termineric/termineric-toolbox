# Import necessary .NET assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GUI Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Read Project Tree"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Folder Path Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select Folder:"
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($label)

# Folder Path TextBox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(100, 20)
$textBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBox)

# Browse Button to Select Folder
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = New-Object System.Drawing.Point(310, 20)
$browseButton.Size = New-Object System.Drawing.Size(60, 20)
$form.Controls.Add($browseButton)

# Function for Folder Selection
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})

# Scan Button
$scanButton = New-Object System.Windows.Forms.Button
$scanButton.Text = "Scan"
$scanButton.Location = New-Object System.Drawing.Point(100, 60)
$scanButton.Size = New-Object System.Drawing.Size(80, 30)
$form.Controls.Add($scanButton)

# Cancel Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(200, 60)
$cancelButton.Size = New-Object System.Drawing.Size(80, 30)
$form.Controls.Add($cancelButton)

# Cancel Button Event - Closes the Form Only
$cancelButton.Add_Click({
    $form.Close()
})

# Scan Button Event - Starts Folder Scan and JSON Creation
$scanButton.Add_Click({
    if (-not (Test-Path -Path $textBox.Text -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid folder.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $folderPath = $textBox.Text
        $folderName = Split-Path -Leaf -Path $folderPath
        $jsonFileName = "$folderName.json"

        # Ensure 'templates' directory exists
        $templateDir = Join-Path -Path $PSScriptRoot -ChildPath "templates"
        if (!(Test-Path -Path $templateDir)) {
            New-Item -ItemType Directory -Path $templateDir | Out-Null
        }

        # JSON file path
        $jsonFilePath = Join-Path -Path $templateDir -ChildPath $jsonFileName

        # Recursive Function to Get Folder Structure
        function Get-FolderStructure {
            param ([string]$folderPath)
            $structure = @()

            foreach ($item in Get-ChildItem -Path $folderPath -Recurse) {
                $fileType = if ($item.PSIsContainer) { "folder" } else { "file" }
                $fileContent = if ($item.Name -ne "Dummy.File" -and -not $item.PSIsContainer) {
                    [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($item.FullName))
                } else {
                    ""
                }
                $structure += [PSCustomObject]@{
                    name = $item.Name
                    type = $fileType
                    content = $fileContent
                    children = if ($fileType -eq "folder") { Get-FolderStructure -folderPath $item.FullName } else { $null }
                }
            }
            return $structure
        }

        # Build Folder Structure and Convert to JSON
        $folderStructure = Get-FolderStructure -folderPath $folderPath
        $jsonOutput = $folderStructure | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($jsonFilePath, $jsonOutput)

        [System.Windows.Forms.MessageBox]::Show("JSON saved to: $jsonFilePath", "Scan Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Close()
    }
})

# Show Form
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
$form.ShowDialog()
