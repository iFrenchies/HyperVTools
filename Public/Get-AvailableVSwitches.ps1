function Get-AvailableVSwitches {
    <#
    .SYNOPSIS
        Retourne la liste des vSwitch Hyper-V disponibles.

    .DESCRIPTION
        Cette fonction récupère tous les vSwitch Hyper-V existants
        et retourne un tableau d’objets contenant :
            - Name
            - SwitchType (Internal, Private, External)
            - NetAdapter (si externe)
            - Notes (ex : NAT détecté)

        Idéal pour alimenter une interface graphique.

    .EXAMPLE
        Get-AvailableVSwitches

    .OUTPUTS
        PSCustomObject[]
    #>

    $switches = Get-VMSwitch

    $results = foreach ($sw in $switches) {

        # Détection NAT éventuelle
        $nat = Get-NetNat | Where-Object {
            $_.Name -eq "NAT-$($sw.Name)"
        }

        # Adaptateur physique si externe
        $adapter = $null
        if ($sw.SwitchType -eq "External") {
            $adapter = ($sw.NetAdapterInterfaceDescription -join ", ")
        }

        [PSCustomObject]@{
            Name       = $sw.Name
            SwitchType = $sw.SwitchType
            NetAdapter = $adapter
            Notes      = if ($nat) { "NAT: $($nat.InternalIPInterfaceAddressPrefix)" } else { "" }
        }
    }

    return $results
}
