function New-CustomVSwitch {
    <#
    .SYNOPSIS
        Crée un vSwitch Hyper-V interne, privé, externe ou NATé.

    .DESCRIPTION
        Cette fonction crée un vSwitch Hyper-V :
            - Interne
            - Privé
            - Externe (nécessite un adaptateur physique)
            - NAT (crée automatiquement l’interface + appelle New-CustomNAT)

        La création du NAT Windows est déléguée à la fonction New-CustomNAT
        pour respecter une architecture modulaire propre.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Internal", "Private", "External", "NAT")]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [string]$AdapterName,

        [Parameter(Mandatory = $false)]
        [string]$NATSubnet
    )

    # Vérification existence
    if (Test-VSwitchName -Name $Name) {
        throw "Un vSwitch nommé '$Name' existe déjà."
    }

    Write-Log -Message "Création du vSwitch '$Name' ($Type)" -Level Info

    switch ($Type) {

        "Internal" {
            New-VMSwitch -Name $Name -SwitchType Internal | Out-Null
            Write-Log -Message "vSwitch interne '$Name' créé." -Level Success
        }

        "Private" {
            New-VMSwitch -Name $Name -SwitchType Private | Out-Null
            Write-Log -Message "vSwitch privé '$Name' créé." -Level Success
        }

        "External" {
            if (-not $AdapterName) {
                throw "Pour un vSwitch externe, vous devez spécifier -AdapterName."
            }

            New-VMSwitch -Name $Name -NetAdapterName $AdapterName -AllowManagementOS $true | Out-Null
            Write-Log -Message "vSwitch externe '$Name' créé sur l'adaptateur '$AdapterName'." -Level Success
        }

        "NAT" {
            if (-not $NATSubnet) {
                throw "Pour un vSwitch NAT, vous devez fournir -NATSubnet (ex : 192.168.100.0/24)."
            }

            # 1. Création du vSwitch interne
            New-VMSwitch -Name $Name -SwitchType Internal | Out-Null

            # 2. Configuration IP de l’interface vEthernet
            $ifName = "vEthernet ($Name)"
            $ip = ($NATSubnet -replace "/.*","1")
            $prefix = ($NATSubnet -replace ".*/","")

            New-NetIPAddress -InterfaceAlias $ifName -IPAddress $ip -PrefixLength $prefix -ErrorAction Stop | Out-Null
            Write-Log -Message "Adresse IP $ip/$prefix appliquée à l’interface '$ifName'." -Level Info

            # 3. Création du NAT via la fonction dédiée
            New-CustomNAT -Name "NAT-$Name" -Prefix $NATSubnet | Out-Null

            Write-Log -Message "vSwitch NAT '$Name' créé avec NAT '$NATSubnet'." -Level Success
        }
    }

    return $Name
}
