# Microsoft.PowerShell_profile.ps1
#
# Profile actions executed when PowerShell starts interactively for the user.
# This file performs environment setup, ensures required directories exist,
# imports commonly used modules (posh-git, oh-my-posh, Terminal-Icons),
# and imports custom local modules from the repository `Modules` folder.
#
# Notes:
# - The profile should avoid an early `return` so module imports always run.
# - Keep long-running or network operations guarded behind checks so startup
#   remains snappy.

# Set variables.

# Default path for local git repositories; defaults to $HOME\source\repos
# Use `$env:DefaultRepoPath` to override.
if ($null -ne $env:DefaultRepoPath -and $env:DefaultRepoPath -ne "") {
    [string] $DefaultRepoPath = $env:DefaultRepoPath
}
else { 
    [string] $DefaultRepoPath = Join-Path -Path $env:USERPROFILE -ChildPath source -AdditionalChildPath repos
}

Write-Host "Default Repo Path: $DefaultRepoPath"

# Default path for custom modules
# Use `$env:CustomModulePath` to override.
if ($null -ne $env:CustomModulePath -and $env:CustomModulePath -ne "") {
    [string] $ModulePath = $env:CustomModulePath
}
else {
    [string] $ModulePath = Join-Path -Path $DefaultRepoPath -ChildPath 'wcjpwsh\Modules'
}

# Create Repos path if it doesn't exist
if (!(Test-Path -Path $DefaultRepoPath)) {
    Write-Host "Creating directory $DefaultRepoPath"
    mkdir $DefaultRepoPath | Out-Null
}

# Import PoshGit
if ($null -ne (Get-Module -Name posh-git -ListAvailable)) {
    Write-Host "Importing Posh-Git"
    Import-Module Posh-Git
}
else {
    Write-Host -ForegroundColor Red "You don't have Posh-Git installed! If you use git, I highly recommend it!`nUse the command 'Install-Module -Name posh-git -Scope AllUsers' from an Admin PowerShell to install "
}

# Import Oh-My-Posh (optional)
# Assume that OMP is installed as a standalone app. If the theme path is
# missing we warn but continue; this prevents the rest of the profile from
# being skipped due to an early return.
if (-not (Test-Path -Path $env:POSH_THEMES_PATH)) {
    Write-Warning "You don't have Oh-My-Posh installed! If you use git, I highly recommend it!`nUse the command`n'winget install JanDeDobbeleer.OhMyPosh --source winget --scope machine --force' from an Admin PowerShell to install"
}
else {
    Write-Host "Loading Oh-My-Posh"
    $env:CustomThemeFileName = Join-Path -Path $env:POSH_THEMES_PATH -ChildPath "customtheme.omp.json"
    # Enable git status integration
    $env:POSH_GIT_ENABLED = $true
    if (!(Test-Path $env:CustomThemeFileName)) {
        $env:CustomThemeFileName = Join-Path -Path $env:POSH_THEMES_PATH -ChildPath "jandedobbeleer.omp.json"
        # Check if the fallback theme exists
        if (!(Test-Path $env:CustomThemeFileName)) {
            Write-Warning "Oh-My-Posh theme file not found: $env:CustomThemeFileName. OMP will not be launched."
            $env:CustomThemeFileName = ""
        }
        else {
            Write-Warning "Custom theme not found. Falling back to default theme."
        }
    }
    if ($env:CustomThemeFileName -ne "") {
        Write-Host "Using Oh-My-Posh theme: $env:CustomThemeFileName"
        # Initialize Oh-My-Posh (if installed). We pipe to Invoke-Expression to
        # allow the OMP initialization code to adjust the session prompt.
        & oh-my-posh init pwsh --config="$env:CustomThemeFileName" | Invoke-Expression
    }
}

# Import Terminal-Icons (optional)
if ($null -ne (Get-Module -Name Terminal-Icons -ListAvailable)) {
    Write-Host "Importing Terminal-Icons"
    Import-Module Terminal-Icons
}
else {
    Write-Warning "You don't have Terminal-Icons installed! If you use git, I highly recommend it!`nUse the command 'Install-Module -Name Terminal-Icons -Scope AllUsers' from an Admin PowerShell to install "
}

# Install PSReadline >= 2.2.0 (required for PredictionViewStyle)
$PSReadlineVersion = (Get-Module -Name PSReadLine).Version

if ($PSReadlineVersion.Major -le 2 -and $PSReadlineVersion.Minor -lt 2) {
    Write-Host "Installing PSReadline Beta" -ForegroundColor Cyan
    Install-Module -Name PSReadLine -AllowPrerelease -Force
}

Import-Module PSReadLine -MinimumVersion 2.2.0 -Force

# Set PSReadline options

# Disable beep on Backspace at beginning of line.
Set-PSReadLineOption -BellStyle None

# Set Prediction Source
Set-PSReadLineOption -PredictionSource History

# Set Edit mode
Set-PSReadLineOption -EditMode Windows

# Set Prediction View
Set-PSReadLineOption -PredictionViewStyle ListView

# PowerShell parameter completion shim for the dotnet CLI
Write-Host "Registering dotnet CLI completion"
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Register winget CLI completion
Write-Host "Registering winget CLI completion"
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Import custom modules from the local `Modules` folder
Write-Host "Importing custom modules from $ModulePath"
if (Test-Path -Path $ModulePath) {
    # Import by manifest so nested modules are processed and exported members
    # are correctly registered.
    $modules = Get-ChildItem -Path $ModulePath -Filter *.psd1 -Recurse
    foreach ($module in $modules) {
        Write-Host "Importing module $($module.BaseName)"
        try {
            Import-Module -Name $module.FullName -DisableNameChecking -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to import module $($module.FullName): $_"
        }
    }
}
else {
    Write-Warning "Modules path not found: $ModulePath"
}

# Export $DefaultRepoPath to the global session and environment for use by other scripts
if ($null -ne $DefaultRepoPath) {
    Set-Variable -Name 'DefaultRepoPath' -Value $DefaultRepoPath -Scope Global -Force
    $env:DefaultRepoPath = $DefaultRepoPath
}