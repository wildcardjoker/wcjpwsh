<#
.SYNOPSIS
    Set a custom Oh-My-Posh prompt from an existing theme.

.DESCRIPTION
    Copies a selected Oh-My-Posh theme file into a user-designated "custom"
    theme file so it becomes the active prompt theme. The function looks for
    themes in a themes directory (by default `CustomThemePath` or
    `POSH_THEMES_PATH`) and copies the selected theme to the path identified
    by `CustomThemeFileName` (or a default `customtheme.omp.json`). The
    function supports interactive selection and tab-completion of available
    themes.

.SYNTAX
    Set-CustomPoshPrompt [-Theme] <String> [-Force] [-WhatIf] [<CommonParameters>]

.PARAMETER Theme
    The base name of the theme to set (without the trailing `.omp` portion).
    If omitted the user will be prompted to choose one of the available
    themes from the themes directory.

.PARAMETER Force
    Overwrite the existing custom theme file if it exists.

.EXAMPLE
    Set-CustomPoshPrompt -Theme MyCoolTheme

    Copies the theme `MyCoolTheme.omp.json` from the themes directory to the
    configured custom theme file.

.EXAMPLE
    Set-CustomPoshPrompt

    Prompts the user to select from the available themes.

.NOTES
    - The function consults the following environment variables (in order) to
      determine where themes live and where the custom theme should be written:
        - `CustomThemePath` (preferred)
        - `POSH_THEMES_PATH` (fallback)
      and for the destination filename:
        - `CustomThemeFileName` (preferred)
      If these are not set reasonable defaults are used.
#>

# Helper: list available themes in a directory
function Get-CustomPoshThemes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    if (-not (Test-Path -Path $Path)) { return @() }

    Get-ChildItem -Path $Path -Filter '*.omp.json' -File -ErrorAction SilentlyContinue |
        ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -replace '\.omp$', '' }
}

function Set-CustomPoshPrompt {
    [Alias('')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    param(
        # The theme to be set as the custom theme (base name, without .omp.json)
        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

                $themes = Get-CustomPoshThemes -Path $env:POSH_THEMES_PATH
                $themes | Where-Object { $_ -like "$WordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
            }
        )]
        $Theme,

        [switch]
        $Force
    )

    begin {
        $desiredExt = '.omp.json'
    }

    process {
        # Interactive selection if no theme provided
        if (-not $Theme) {
            $available = Get-CustomThemes -Path $env:POSH_THEMES_PATH
            if (-not $available -or $available.Count -eq 0) { throw "No themes found in '$env:POSH_THEMES_PATH'" }

            $pick = $available | Out-GridView -Title 'Select a theme to set as custom' -PassThru
            if (-not $pick) { return }
            $Theme = $pick
        }

        # Normalize base name (strip any extensions user might have supplied)
        $base = [System.IO.Path]::GetFileNameWithoutExtension($Theme) -replace '\.omp$', ''
        $source = Join-Path -Path $env:POSH_THEMES_PATH -ChildPath ("$base$desiredExt")

        if (-not (Test-Path -Path $source -PathType Leaf)) {
            Write-Warning "Theme file '$source' not found; skipping."
            continue
        }

        $action = if ($Force) { 'Set (overwrite)' } else { 'Set' }
        if ($PSCmdlet.ShouldProcess($source, "$action custom theme -> $source")) {
            try {
                # Save the custom theme file path to the environment variable
                [System.Environment]::SetEnvironmentVariable('CustomThemeFileName', $source, 'User')
                $env:CustomThemeFileName = $source # Sync for current session
                Clear-Host
                Write-Host -ForegroundColor Cyan "Reloading profile to apply new theme..."
                . $PROFILE
            }
            catch {
                Write-Error "Failed to copy theme: $_"
            }
        }
            }

    end {
    }
}