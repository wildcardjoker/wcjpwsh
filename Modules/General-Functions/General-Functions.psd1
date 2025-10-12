@{
    GUID = 'a3c5f7d2-9b84-4f2b-8c2d-1d5a2f7e6b9c'
    Author = 'wildcardjoker'
    CompanyName = ''
    Copyright = ''
    Description = 'General-purpose helper functions: Add-PathFolder, Edit-History, Get-PathVariable, Rename-NoSpaces, Set-LocationUp, Show-AllColours, Update-Profile.'
    ModuleVersion = '1.0.0.0'
    PowerShellVersion = '5.1'
    RootModule = ''
    NestedModules = @(
        'Add-PathFolder.psm1',
        'Edit-History.psm1',
        'Get-PathVariable.psm1',
        'Rename-NoSpaces.psm1',
        'Set-LocationUp.psm1',
        'Show-AllColours.psm1',
        'Update-Profile.psm1'
    )
    FunctionsToExport = @(
        'Add-PathFolder',
        'Edit-History',
        'Get-PathVariable',
        'Rename-NoSpaces',
        'Set-LocationUp',
        'Show-AllColours',
        'Update-Profile'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @(
        'sr',
        'up'
    )
    PrivateData = @{
        PSData = @{
            Tags = @('utility','general','wcjpwsh')
            ProjectUri = ''
            ReleaseNotes = ''
        }
    }
}
