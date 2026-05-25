function New-CustomVM {
    <#
    .SYNOPSIS
        Création automatisée d'une machine virtuelle Hyper-V.

    .DESCRIPTION
        Cette fonction crée une VM Hyper-V avec :
            - Nom personnalisé
            - CPU / RAM
            - Disques dynamiques multiples
            - Connexion à un vSwitch existant OU auto-création d’un vSwitch
            - Ajout d’un lecteur DVD
            - Montage ISO + boot automatique
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [int]$CPU,

        [Parameter(Mandatory = $true)]
        [int]$RAM,

        [Parameter(Mandatory = $true)]
        [array]$Disks,

        [Parameter(Mandatory = $false)]
        [string]$SwitchName,

        [Parameter(Mandatory = $false)]
        [ValidateSet("None","Internal","NAT")]
        [string]$AutoVSwitchType = "None",

        [Parameter(Mandatory = $false)]
        [string]$AutoVSwitchSubnet,

        [Parameter(Mandatory = $false)]
        [string]$AutoVSwitchName,

        [Parameter(Mandatory = $false)]
        [string]$ISOPath
    )

    Write-Log -Message "Création de la VM '$Name'" -Level Info

    # Vérifications
    if (Test-VMName -Name $Name) {
        throw "Une VM nommée '$Name' existe déjà."
    }

    if ($ISOPath -and -not (Test-Path $ISOPath)) {
        throw "Le fichier ISO '$ISOPath' est introuvable."
    }

    foreach ($disk in $Disks) {
        if ($disk.SizeGB -lt 1) {
            throw "La taille du disque '$($disk.Name)' doit être d'au moins 1 Go."
        }
    }

    # --- Auto-création du vSwitch ---
    if (-not $SwitchName) {

        if ($AutoVSwitchType -eq "None") {
            throw "Aucun vSwitch fourni et AutoVSwitchType=None. Impossible de continuer."
        }

        if (-not $AutoVSwitchName) {
            $AutoVSwitchName = "vSwitch-$Name-$AutoVSwitchType"
        }

        Write-Log -Message "Aucun vSwitch fourni : création automatique d'un vSwitch '$AutoVSwitchType'." -Level Warning

        switch ($AutoVSwitchType) {

            "Internal" {
                $SwitchName = New-CustomVSwitch -Name $AutoVSwitchName -Type Internal
            }

            "NAT" {
                if (-not $AutoVSwitchSubnet) {
                    throw "Pour un vSwitch NAT, vous devez fournir -AutoVSwitchSubnet (ex : 192.168.200.0/24)."
                }

                $SwitchName = New-CustomVSwitch -Name $AutoVSwitchName -Type NAT -NATSubnet $AutoVSwitchSubnet
            }
        }

        Write-Log -Message "vSwitch '$SwitchName' créé automatiquement." -Level Success
    }

    # --- Dossiers VM ---
    $hostConfig = Get-VMHost
    $VMPath  = Join-Path $hostConfig.VirtualMachinePath $Name
    $VHDPath = Join-Path $hostConfig.VirtualHardDiskPath $Name

    New-Item -ItemType Directory -Path $VMPath -Force | Out-Null
    New-Item -ItemType Directory -Path $VHDPath -Force | Out-Null

    # --- Création VM ---
    Write-Log -Message "Création de la VM Hyper-V..." -Level Info
    New-VM -Name $Name -MemoryStartupBytes ($RAM * 1MB) -Generation 2 -Path $VMPath | Out-Null

    # CPU
    Set-VMProcessor -VMName $Name -Count $CPU
    Write-Log -Message "CPU configuré : $CPU vCPU." -Level Info

    # Lecteur DVD
    Add-VMDvdDrive -VMName $Name -ControllerNumber 0 -ControllerLocation 1 | Out-Null

    # ISO + Boot
    if ($ISOPath) {
        Set-VMDvdDrive -VMName $Name -Path $ISOPath
        Write-Log -Message "ISO monté : $ISOPath" -Level Info

        $dvd = Get-VMDvdDrive -VMName $Name

        $maxWait = 10
        $waited = 0
        do {
            $firmware = Get-VMFirmware -VMName $Name
            $dvdInFirmware = $firmware.BootOrder | Where-Object { $_.Device -eq $dvd.Device }

            if (-not $dvdInFirmware) {
                Start-Sleep -Seconds 1
                $waited++
            }
        } while (-not $dvdInFirmware -and $waited -lt $maxWait)

        if ($dvdInFirmware) {
            $newBootOrder = @($dvd) + ($firmware.BootOrder | Where-Object { $_.Device -ne $dvd.Device })
            Set-VMFirmware -VMName $Name -BootOrder $newBootOrder
            Write-Log -Message "Boot configuré sur le DVD." -Level Success
        }
        else {
            Write-Log -Message "Impossible de détecter le lecteur DVD dans le firmware." -Level Error
        }
    }

    # --- Disques ---
    Write-Log -Message "Création des disques..." -Level Info

    $DiskIndex = 0
    foreach ($disk in $Disks) {
        $DiskFile = "$VHDPath\$($disk.Name).vhdx"
        $SizeBytes = $disk.SizeGB * 1GB

        New-VHD -Path $DiskFile -Dynamic -SizeBytes $SizeBytes | Out-Null

        if ($DiskIndex -eq 0) {
            Add-VMHardDiskDrive -VMName $Name -Path $DiskFile
        }
        else {
            Add-VMHardDiskDrive -VMName $Name -Path $DiskFile -ControllerType SCSI
        }

        Write-Log -Message "Disque '$($disk.Name)' créé : $($disk.SizeGB) Go." -Level Info
        $DiskIndex++
    }

    # --- Réseau ---
    $adapter = Get-VMNetworkAdapter -VMName $Name | Select-Object -First 1
    Connect-VMNetworkAdapter -VMNetworkAdapter $adapter -SwitchName $SwitchName
    Write-Log -Message "VM connectée au vSwitch '$SwitchName'." -Level Success

    # --- Résumé ---
    Write-Log -Message "VM '$Name' créée avec succès." -Level Success
}
