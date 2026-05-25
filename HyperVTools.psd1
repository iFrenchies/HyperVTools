@{
    # --- Informations générales ---
    RootModule        = 'HyperVTools.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b7c1a8f0-2c4e-4e3d-9f7d-9b1c2e4f1234'
    Author            = 'Stéphane'
    CompanyName       = 'Stéphane'
    Copyright         = '(c) Stéphane'
    Description       = 'Module Hyper-V avancé : création de VM, vSwitch, NAT, et outils associés.'

    # --- Compatibilité ---
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop','Core')

    # --- Fichiers ---
    FileList = @(
        'HyperVTools.psm1',
        'Public\New-CustomVM.ps1',
        'Public\New-CustomVSwitch.ps1',
        'Public\New-CustomNAT.ps1',
        'Public\Get-AvailableVSwitches.ps1',
        'Private\Test-VMName.ps1',
        'Private\Test-VSwitchName.ps1',
        'Private\Write-Log.ps1'
    )

    # --- Export ---
    FunctionsToExport = @(
        'New-CustomVM',
        'New-CustomVSwitch',
        'New-CustomNAT',
        'Get-AvailableVSwitches'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # --- Dépendances éventuelles ---
    RequiredModules = @()

    # --- Informations supplémentaires ---
    PrivateData = @{
        PSData = @{
            Tags       = @('Hyper-V','VM','Virtualization','NAT','vSwitch')
            ProjectUri = 'https://github.com/iFrenchies/HyperVTools'
            LicenseUri = 'https://github.com/iFrenchies/HyperVTools/blob/main/LICENSE'
        }
    }

}
