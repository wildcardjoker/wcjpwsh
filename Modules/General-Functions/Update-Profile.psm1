<#
.SYNOPSIS
    Copy a development profile file into the current user's PowerShell profile.

.DESCRIPTION
    Copies a PowerShell profile file from a development repository into the
    current user's profile file location ($Profile). The cmdlet supports
    ShouldProcess so callers can use -WhatIf or -Confirm. Basic validation
    is performed to ensure the source exists and the destination directory
    is present (created if necessary).

.PARAMETER SourcePath
    Path to the source profile file. Defaults to a path under the user's
    Documents/Source directory based on $env:USERPROFILE. You can supply an
    absolute path if your repository is located elsewhere.

.PARAMETER Force
    Overwrite the destination profile file if it already exists.

.EXAMPLE
    Update-Profile
    Copies the default source profile into the current user's $Profile.

.EXAMPLE
    Update-Profile -SourcePath C:\Code\myrepo\Scripts\Microsoft.PowerShell_profile.ps1 -Force
    Copies the specified source profile into $Profile, overwriting if it
    already exists.

.NOTES
    - This function writes errors to the error stream on failure.
    - The function does not return an object; it performs a side-effect.
#>

function Update-Profile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Position = 0)]
        [string]
        $SourcePath = (Join-Path -Path $(Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Microsoft.PowerShell_profile.ps1'),

        [switch]
        $Force
    )

    # Resolve and validate the source path
    if (-not (Test-Path -LiteralPath $SourcePath)) {
        Write-Error "Source profile not found: '$SourcePath'"
        Write-Host "We wanted to copy from $(Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent)"
        
        return
    }

    $destination = $PROFILE

    # Ensure destination directory exists
    $destDir = Split-Path -Path $destination -Parent
    if ($destDir -and -not (Test-Path -Path $destDir)) {
        try {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create destination directory '$destDir': $_"
            return
        }
    }

    $action = "Copy '$SourcePath' to '$destination'"
    if ($PSCmdlet.ShouldProcess($destination, $action)) {
        try {
            Copy-Item -LiteralPath $SourcePath -Destination $destination -Force:$Force.IsPresent -ErrorAction Stop
            Write-Verbose "Profile copied to $destination"
        }
        catch {
            Write-Error "Failed to copy profile: $_"
        }
    }
}
