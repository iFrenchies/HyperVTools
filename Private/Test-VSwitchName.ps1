function Test-VSwitchName {
    <#
    .SYNOPSIS
        Vérifie si un vSwitch Hyper-V existe déjà avec un nom donné.

    .DESCRIPTION
        Retourne $true si un vSwitch portant ce nom existe,
        sinon $false. Utile avant création ou suppression.

    .PARAMETER Name
        Nom du vSwitch à tester.

    .EXAMPLE
        Test-VSwitchName -Name "vSwitch-LAB"
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $sw = Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue
    return [bool]($sw)
}
