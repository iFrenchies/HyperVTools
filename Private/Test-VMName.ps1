function Test-VMName {
    <#
    .SYNOPSIS
        Vérifie si une VM existe déjà avec un nom donné.

    .DESCRIPTION
        Retourne $true si une machine virtuelle Hyper-V portant ce nom existe,
        sinon $false. Idéal pour valider un nom avant création.

    .PARAMETER Name
        Nom de la VM à tester.

    .EXAMPLE
        Test-VMName -Name "LAB-DC01"
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $vm = Get-VM -Name $Name -ErrorAction SilentlyContinue
    return [bool]($vm)
}
