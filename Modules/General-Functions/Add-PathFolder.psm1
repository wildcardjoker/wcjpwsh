<#
.Synopsis
    Add a directory to the $env:PATH variable
.DESCRIPTION
    Add a directory to the $env:PATH variable if it does not already exist
.PARAMETER Path
    The path to be added to the PATH variable
.PARAMETER Parameter2
    Parameter2Description
.INPUTS
    None
.OUTPUTS
    None
.EXAMPLE
    Add-PathFolder -Path C:\MyApps

    Add the folder C:\MyApps to the PATH environment variable
#>

function Add-PathFolder {
    [Alias('')]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default')]
    Param
    (
        # The path to be added to the PATH variable
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $Path
    )

    # Code executes from here

    # Setup
    Begin {
        $PathRegistryKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
        $currentPath = (Get-ItemProperty -Path $PathRegistryKey -Name PATH).path
        $emptyPath = [string]::IsNullOrWhiteSpace($Path) -or $path -eq ''
        $existingPath = $currentPath -like "*$Path*"

        Write-Verbose "Path:               $Path"
        Write-Verbose "Null or empty path? $emptyPath"
        Write-Verbose "Existing Path?      $existingPath"

    } # Begin

    Process {
        if (!($emptyPath -or $existingPath)) {
            $newPath = "$currentPath;$Path"
            if ($PSCmdlet.ShouldProcess("Path", "Add $Path")) {
                Set-ItemProperty -Path $PathRegistryKey -Name PATH -Value $newPath
            } # ShouldProcess
        }
    } # Process

    # Clean up
    End {
    
    } # End
}