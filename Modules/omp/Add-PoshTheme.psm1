<#
.SYNOPSIS
    Install an Oh-My-Posh theme file into the user's PoshThemes directory.

.DESCRIPTION
    Copies one or more Oh-My-Posh theme files into the directory specified by
    the `POSH_THEMES_PATH` environment variable. If the environment variable
    is not set the function will return an error. The function normalizes the
    theme filename to use the ".omp.json" extension if needed.

.SYNTAX
    Add-PoshTheme [[-Source] <String[]>] [-Force] [-WhatIf] [<CommonParameters>]

.PARAMETER Source
    Path(s) to the theme file(s) to copy. If omitted the user will be
    interactively prompted to select one or more files.

.PARAMETER Force
    If specified the copy operation will overwrite existing files in the
    destination.

.EXAMPLE
    Add-PoshTheme -Source C:\themes\mytheme.omp.json

    Copies the specified theme into the Posh themes directory.

.EXAMPLE
    Get-ChildItem .\themes -Filter *.json | Add-PoshTheme

    Pipeline multiple theme files into the function.

.NOTES
    - Requires the `POSH_THEMES_PATH` environment variable to be set to the
      target themes directory.
    - The function uses `ShouldProcess` so you can preview changes with
      `-WhatIf`.
#>

function Add-PoshTheme {
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='Default')]
    Param(
        [Parameter(ParameterSetName='Default', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string[]]
        $Source,

        [switch]
        $Force
    )

    Begin {
        if ([string]::IsNullOrWhiteSpace($env:POSH_THEMES_PATH)) {
            Throw "Environment variable POSH_THEMES_PATH is not set. Set it to your themes directory before running this function."
        }

        $targetDir = $env:POSH_THEMES_PATH
        $desiredExt = '.omp.json'
    }

    Process {
        # If no sources supplied, prompt the user to pick files
        if (-not $Source -or $Source.Count -eq 0) {
            $picked = Get-ChildItem -Path . -Filter *.json -File -Recurse -ErrorAction SilentlyContinue | Out-GridView -Title 'Select theme file(s) to install' -PassThru
            if ($picked) { $Source = $picked.FullName }
        }

        foreach ($s in $Source) {
            if (-not (Test-Path -Path $s -PathType Leaf)) {
                Write-Warning "Source file '$s' does not exist; skipping."
                continue
            }

            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($s)
            $newFileName = "$baseName$desiredExt"
            $dest = Join-Path -Path $targetDir -ChildPath $newFileName

            $action = if ($Force) { 'Copy (overwrite)' } else { 'Copy' }

            if ($PSCmdlet.ShouldProcess($s, "$action to $dest")) {
                try {
                    Copy-Item -Path $s -Destination $dest -Force:$Force.IsPresent -ErrorAction Stop
                    Write-Verbose "Copied '$s' to '$dest'"
                } catch {
                    Write-Error "Failed to copy '$s' to '$dest': $_"
                }
            }
        }
    }

    End {
    }
}