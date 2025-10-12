@{
    GUID              = 'b2d9e1a4-2c8f-4a9b-8e32-3a7f4c1d2e5f'
    Author            = 'wildcardjoker'
    CompanyName       = ''
    Copyright         = ''
    Description       = 'Small git helper functions (Get-GitIgnore).'
    ModuleVersion     = '1.0.0.0'
    PowerShellVersion = '5.1'
    RootModule        = ''
    NestedModules     = @(
        'Get-GitIgnore.psm1',
        'Get-GitRepoStatus.psm1'
    )
    FunctionsToExport = @(
        'Get-GitIgnore',
        'Get-GitRepoStatus',
        'Get-GitRepoStatusTable',
        'Get-GitRepoStatusDetails'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @(
        'gsr',
        'gsrt',
        'gsrd'
    )
    PrivateData       = @{
        PSData = @{
            Tags         = @('git', 'helpers')
            ProjectUri   = ''
            ReleaseNotes = ''
        }
    }
}
