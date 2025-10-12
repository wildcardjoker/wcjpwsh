<#
.SYNOPSIS
    Add a directory to the system PATH environment variable.

.DESCRIPTION
    Adds a directory to the machine-level PATH stored in the registry
    (HKLM:\System\CurrentControlSet\Control\Session Manager\Environment). The
    function validates the input, normalizes the path, and avoids adding a
    duplicate entry. Use -WhatIf to preview changes.

.SYNTAX
    Add-PathFolder [-Path] <String> [<CommonParameters>]

.PARAMETER Path
    The directory path to add to the system PATH. Can be a relative or
    absolute path; it will be resolved and normalized. If the path does not
    exist on disk the function will throw a terminating error unless
    -Force is used.

.PARAMETER Force
    If present, bypasses the existence check for the path on disk and adds
    the value to PATH anyway.

.EXAMPLE
    Add-PathFolder -Path 'C:\MyApps'

    Adds C:\MyApps to the system PATH if it isn't already present.

.EXAMPLE
    Add-PathFolder -Path '..\\tools' -WhatIf

    Shows what would be changed (preview) when adding a relative path
    resolved against the current working directory.

.OUTPUTS
    None. This function updates the registry.

.NOTES
    - This modifies the machine PATH (HKLM). A restart or a logoff/logon may be
      required for some processes to pick up the change.
    - Running from an elevated PowerShell session is required to update the
      machine-level PATH registry key.
#>

function Add-PathFolder {
    [Alias('')]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default')]
    Param(
        # The path to be added to the PATH variable
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force
    )

    # Code executes from here

    # Setup
    Begin {
        $PathRegistryKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
        try {
            $currentPath = (Get-ItemProperty -Path $PathRegistryKey -Name PATH -ErrorAction Stop).PATH
        } catch {
            Throw "Unable to read system PATH from registry. Run PowerShell elevated and try again. $_"
        }

        # Normalize the user-supplied path to a full absolute path when possible
        $resolvedPath = try {
            (Resolve-Path -Path $Path -ErrorAction Stop).ProviderPath
        } catch {
            $Path
        }

        $emptyPath = [string]::IsNullOrWhiteSpace($resolvedPath) -or $resolvedPath -eq ''

        # Use a robust check to avoid partial matches: split PATH into entries
        $pathEntries = $currentPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $existingPath = $pathEntries -contains $resolvedPath

        Write-Verbose "Path (input):       $Path"
        Write-Verbose "Path (resolved):    $resolvedPath"
        Write-Verbose "Null or empty path? $emptyPath"
        Write-Verbose "Existing Path?      $existingPath"

    } # Begin

    Process {
        if ($emptyPath) { return }

        if ($existingPath) {
            Write-Verbose "The path '$resolvedPath' is already present in the system PATH. No change made."
            return
        }

        $newPath = if ($currentPath -and $currentPath.Trim() -ne '') { "$currentPath;$resolvedPath" } else { $resolvedPath }

        if (-not $Force) {
            # If the resolved path looks like a filesystem path, require it to exist
            if ($resolvedPath -and (Test-Path -Path $resolvedPath -PathType Container) -ne $true) {
                Throw "Path '$resolvedPath' does not exist. Use -Force to add non-existent paths."
            }
        }

        if ($PSCmdlet.ShouldProcess("Path", "Add $resolvedPath")) {
            Set-ItemProperty -Path $PathRegistryKey -Name PATH -Value $newPath -ErrorAction Stop
            Write-Verbose "Updated system PATH in registry."
        }
    } # Process

    # Clean up
    End {
    
    } # End
}