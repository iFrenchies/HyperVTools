function New-CustomNAT {
    <#
    .SYNOPSIS
        Crée un objet NAT Windows pour un réseau interne Hyper-V.

    .DESCRIPTION
        Cette fonction crée un objet NAT Windows (New-NetNat) sur un préfixe IP donné.
        Elle est pensée pour être utilisée avec un vSwitch interne Hyper-V
        dont l’interface vEthernet est déjà configurée avec une adresse IP
        appartenant à ce préfixe.

    .PARAMETER Name
        Nom de l’objet NAT (ex : NAT-vSwitch-LAB).

    .PARAMETER Prefix
        Préfixe réseau interne (ex : 192.168.200.0/24).

    .EXAMPLE
        New-CustomNAT -Name "NAT-vSwitch-LAB" -Prefix "192.168.200.0/24"

    .OUTPUTS
        Microsoft.Management.Infrastructure.CimInstance (objet NetNat)
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Prefix
    )

    # Vérifie si un NAT du même nom existe déjà
    $existingNat = Get-NetNat -Name $Name -ErrorAction SilentlyContinue
    if ($existingNat) {
        throw "Un objet NAT nommé '$Name' existe déjà (Prefix: $($existingNat.InternalIPInterfaceAddressPrefix))."
    }

    # Vérifie si un NAT existe déjà sur ce préfixe
    $existingPrefix = Get-NetNat | Where-Object {
        $_.InternalIPInterfaceAddressPrefix -eq $Prefix
    }

    if ($existingPrefix) {
        throw "Un objet NAT existe déjà sur le préfixe '$Prefix' (Name: $($existingPrefix.Name))."
    }

    Write-Host "=== Création du NAT '$Name' sur le préfixe '$Prefix' ===" -ForegroundColor Cyan

    $nat = New-NetNat -Name $Name -InternalIPInterfaceAddressPrefix $Prefix -ErrorAction Stop

    Write-Host "NAT '$Name' créé avec succès." -ForegroundColor Green

    return $nat
}
