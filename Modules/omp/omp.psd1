@{
    # Module manifest for the 'omp' module (Oh-My-Posh helpers)
    RootModule = '' # RootModule not used because we load nested modules
    ModuleVersion = '1.0.0'
    GUID = 'd8b2a2d5-0000-4f7a-9c3e-000000000000'
    Author = 'wildcardjoker'
    CompanyName = ''
    Copyright = '(c) wildcardjoker'
    Description = 'Helpers for Oh-My-Posh (Add-PoshTheme, Set-CustomPoshPrompt)'
    PowerShellVersion = '5.1'
    # Use NestedModules so the .psm1 files are treated as nested modules
    NestedModules = @(
        'Add-PoshTheme.psm1',
        'Set-CustomPoshPrompt.psm1'
    )
    # Exported functions are left to each nested module; module manifest does not
    # need to list them here unless you want to control exported members centrally.
    FunctionsToExport = @(
        'Add-PoshTheme',
        'Get-CustomPoshThemes',
        'Set-CustomPoshPrompt'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    FileList = @()
    PrivateData = @{
        PSData = @{
            Tags = @('posh','omp','oh-my-posh')
            LicenseUri = ''
            ProjectUri = ''
        }
    }
}
