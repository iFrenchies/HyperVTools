Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Chargement du module HyperVTools
try {
    Import-Module HyperVTools -ErrorAction Stop
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Impossible de charger le module HyperVTools.`nVérifie qu'il est installé.")
    return
}

# --- Fenêtre principale ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "HyperVTools - Création de VM"
$form.Size = New-Object System.Drawing.Size(850,600)
$form.StartPosition = "CenterScreen"

# --- Onglets ---
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = "Fill"
$form.Controls.Add($tabs)

# ============================================================
# ONGLET 1 : GENERAL
# ============================================================
$tabGeneral = New-Object System.Windows.Forms.TabPage
$tabGeneral.Text = "Général"
$tabs.TabPages.Add($tabGeneral)

# Nom VM
$lblName = New-Object System.Windows.Forms.Label
$lblName.Text = "Nom de la VM :"
$lblName.Location = "20,20"
$tabGeneral.Controls.Add($lblName)

$txtName = New-Object System.Windows.Forms.TextBox
$txtName.Location = "180,18"
$txtName.Width = 250
$tabGeneral.Controls.Add($txtName)

# CPU
$lblCPU = New-Object System.Windows.Forms.Label
$lblCPU.Text = "CPU :"
$lblCPU.Location = "20,60"
$tabGeneral.Controls.Add($lblCPU)

$txtCPU = New-Object System.Windows.Forms.NumericUpDown
$txtCPU.Location = "180,58"
$txtCPU.Minimum = 1
$txtCPU.Maximum = 32
$txtCPU.Value = 2
$tabGeneral.Controls.Add($txtCPU)

# RAM
$lblRAM = New-Object System.Windows.Forms.Label
$lblRAM.Text = "RAM (MB) :"
$lblRAM.Location = "20,100"
$tabGeneral.Controls.Add($lblRAM)

$txtRAM = New-Object System.Windows.Forms.NumericUpDown
$txtRAM.Location = "180,98"
$txtRAM.Minimum = 1024
$txtRAM.Maximum = 262144
$txtRAM.Value = 4096
$tabGeneral.Controls.Add($txtRAM)

# ISO
$lblISO = New-Object System.Windows.Forms.Label
$lblISO.Text = "Fichier ISO :"
$lblISO.Location = "20,140"
$tabGeneral.Controls.Add($lblISO)

$txtISO = New-Object System.Windows.Forms.TextBox
$txtISO.Location = "180,138"
$txtISO.Width = 450
$tabGeneral.Controls.Add($txtISO)

$btnISO = New-Object System.Windows.Forms.Button
$btnISO.Text = "Parcourir..."
$btnISO.Location = "650,136"
$btnISO.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "ISO Files (*.iso)|*.iso"
    if ($dialog.ShowDialog() -eq "OK") {
        $txtISO.Text = $dialog.FileName
    }
})
$tabGeneral.Controls.Add($btnISO)

# ============================================================
# ONGLET 2 : DISQUES
# ============================================================
$tabDisks = New-Object System.Windows.Forms.TabPage
$tabDisks.Text = "Disques"
$tabs.TabPages.Add($tabDisks)

$lblDiskOS = New-Object System.Windows.Forms.Label
$lblDiskOS.Text = "Taille disque OS (GB) :"
$lblDiskOS.Location = "20,20"
$tabDisks.Controls.Add($lblDiskOS)

$txtDiskOS = New-Object System.Windows.Forms.NumericUpDown
$txtDiskOS.Location = "200,18"
$txtDiskOS.Minimum = 20
$txtDiskOS.Maximum = 500
$txtDiskOS.Value = 40
$tabDisks.Controls.Add($txtDiskOS)

# ============================================================
# ONGLET 3 : RÉSEAU
# ============================================================
$tabNetwork = New-Object System.Windows.Forms.TabPage
$tabNetwork.Text = "Réseau"
$tabs.TabPages.Add($tabNetwork)

$lblSwitch = New-Object System.Windows.Forms.Label
$lblSwitch.Text = "vSwitch :"
$lblSwitch.Location = "20,20"
$tabNetwork.Controls.Add($lblSwitch)

$cmbSwitch = New-Object System.Windows.Forms.ComboBox
$cmbSwitch.Location = "180,18"
$cmbSwitch.Width = 250
$cmbSwitch.DropDownStyle = "DropDownList"
$tabNetwork.Controls.Add($cmbSwitch)

# Charger les vSwitch existants
try {
    $cmbSwitch.Items.AddRange((Get-AvailableVSwitches))
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Erreur lors du chargement des vSwitch.")
}

# Création d’un vSwitch
$btnNewSwitch = New-Object System.Windows.Forms.Button
$btnNewSwitch.Text = "Créer un vSwitch"
$btnNewSwitch.Location = "450,16"
$btnNewSwitch.Add_Click({
    $name = Read-Host "Nom du vSwitch"
    if ($name) {
        try {
            New-CustomVSwitch -Name $name -Type Internal
            $cmbSwitch.Items.Clear()
            $cmbSwitch.Items.AddRange((Get-AvailableVSwitches))
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Impossible de créer le vSwitch.")
        }
    }
})
$tabNetwork.Controls.Add($btnNewSwitch)

# ============================================================
# ONGLET 4 : CREATION
# ============================================================
$tabCreate = New-Object System.Windows.Forms.TabPage
$tabCreate.Text = "Créer la VM"
$tabs.TabPages.Add($tabCreate)

$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = "Créer la VM"
$btnCreate.Location = "20,20"
$btnCreate.Width = 200
$btnCreate.Height = 40
$btnCreate.Add_Click({

    if (-not $txtName.Text) {
        [System.Windows.Forms.MessageBox]::Show("Le nom de la VM est obligatoire.")
        return
    }

    $params = @{
        Name  = $txtName.Text
        CPU   = [int]$txtCPU.Value
        RAM   = [int]$txtRAM.Value
        Disks = @(
            @{ Name="OS"; SizeGB=[int]$txtDiskOS.Value }
        )
        ISOPath = $txtISO.Text
    }

    if ($cmbSwitch.SelectedItem) {
        $params.Add("VSwitchName", $cmbSwitch.SelectedItem)
    }

    try {
        New-CustomVM @params
        [System.Windows.Forms.MessageBox]::Show("VM créée avec succès !")
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la création de la VM.`n$($_.Exception.Message)")
    }
})
$tabCreate.Controls.Add($btnCreate)

# --- Affichage ---
$form.ShowDialog()
