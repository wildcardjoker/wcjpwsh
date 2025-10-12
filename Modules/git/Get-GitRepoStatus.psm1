<#
.SYNOPSIS
    Display concise Git status for repositories in a directory.

.DESCRIPTION
    Scans a target directory for Git working copies and displays a short
   , human-friendly summary for each repository. The function uses
    `git -C <path>` so it does not change your current location.

.PARAMETER Path
    The directory to scan for Git repositories. Defaults to $CodePath if set
    (commonly defined in your profile) or the current directory.

.PARAMETER Recurse
    When specified, searches subdirectories recursively for repositories.

.PARAMETER ShowDetails
    When specified, shows the `git status --short` output for repositories
    that are not clean.

.PARAMETER OutOfSyncOnly
    When specified, only returns repositories that have changes (modified files,
    ahead of remote, or behind remote). Clean repositories are filtered out.

.EXAMPLE
    Show-GitStatus
    Scans the default working-copy directory and displays a summary.

.EXAMPLE
    Show-GitStatus -Path C:\gitwc -Recurse -ShowDetails
    Scans C:\gitwc recursively and shows short status lines for modified repos.

.NOTES
    - This function avoids changing the caller's location and tolerates
      repositories with no upstream configured.
#>

function Get-GitRepoStatus {
    [CmdletBinding()]
    [Alias('grs')]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path = $(if ($Script:CodePath) { $Script:CodePath } elseif ($global:CodePath) { $global:CodePath } else { $CodePath }),

        [switch]
        $Recurse,

        [switch]
        $ShowDetails,

        [switch]
        $OutOfSyncOnly = $false
    )

    begin {

        Write-Verbose "OutOfSyncOnly: $OutOfSyncOnly"
        # Resolve a reasonable default for Path
        if ([string]::IsNullOrWhiteSpace($Path)) { $Path = Get-Location }

        if (-not (Test-Path -Path $Path)) {
            Write-Error "Path not found: $Path"
            return
        }

        # Build the directory list (top-level or recursive)
        $searchParams = @{ Path = $Path; Directory = $true }
        $dirs = if ($Recurse) { Get-ChildItem @searchParams -Recurse -ErrorAction SilentlyContinue } else { Get-ChildItem @searchParams -ErrorAction SilentlyContinue }

        # If no subdirectories found and Path itself is a directory, include it
        if ($dirs.Count -eq 0) { $dirs = @(Get-Item -Path $Path) }
    }

    process {
        foreach ($d in $dirs) {
            $repoPath = $d.FullName

            # Detect if repo: prefer git -C ... rev-parse for robust check
            $isRepo = $false
            try {
                $isRepo = (& git -C $repoPath rev-parse --is-inside-work-tree 2>$null) -eq 'true'
            }
            catch {
                $isRepo = $false
            }

            if (-not $isRepo) { continue }

            # Get porcelain=2 status with branch info so we can detect ahead/behind
            $gitOutput = & git -C $repoPath status --porcelain=2 --branch 2>$null
            if ($LASTEXITCODE -ne 0 -or -not $gitOutput) {
                Write-Verbose "Failed to query git at: $repoPath"
                continue
            }

            # Parse branch ahead/behind info
            $branchAbLine = $gitOutput | Where-Object { $_ -like '# branch.ab*' }
            $ahead = 0; $behind = 0
            if ($branchAbLine) {
                if ($branchAbLine -match '\+([0-9]+) -([0-9]+)') { $ahead = [int]$matches[1]; $behind = [int]$matches[2] }
            }

            # Determine if there are working-tree changes (non-comment lines in porcelain)
            $changes = $gitOutput | Where-Object { $_ -and ($_ -notlike '#*') }
            $isClean = ($changes.Count -eq 0)

            # Create PSCustomObject for the repo
            $displayName = Split-Path -Path $repoPath -Leaf
            $statusParts = @()
            if ($ahead -gt 0) { $statusParts += "ahead:$ahead" }
            if ($behind -gt 0) { $statusParts += "behind:$behind" }
            if (-not $isClean) { $statusParts += 'modified' }
            if ($statusParts.Count -eq 0) { $statusParts += 'clean' }

            # Determine status for object properties
            $status = $statusParts -join ', '
            $statusColor = ($statusParts -contains 'clean') ? 'Green' :
                           ((($statusParts -like '*behind*').Count) -gt 0 ? 'Red' :
                           ((($statusParts -match 'ahead').Count) -gt 0 ? 'Blue' :
                           ($statusParts -contains 'modified' ? 'Yellow' : 'Cyan')))

            # Get details if requested
            $details = $null
            if ($ShowDetails -and -not $isClean) {
                $short = & git -C $repoPath status --short 2>$null
                if ($short) { $details = $short -join [Environment]::NewLine }
            }

            # Filter for OutOfSyncOnly if requested
            if ($OutOfSyncOnly -and $isClean -and $ahead -eq 0 -and $behind -eq 0) {
                continue
            }

            # Output PSCustomObject
            [PSCustomObject]@{
                Repository  = $displayName
                Path        = $repoPath
                Status      = $status
                IsClean     = $isClean
                Ahead       = $ahead
                Behind      = $behind
                StatusColor = $statusColor
                Details     = $details
            }
        }
    }

    end {
        # nothing to clean up; we never changed location
    }
}

function Get-GitRepoStatusTable {
    [CmdletBinding()]
    [Alias('grst')]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path = $(if ($Script:CodePath) { $Script:CodePath } elseif ($global:CodePath) { $global:CodePath } else { $CodePath }),

        [switch]
        $Recurse,

        [switch] $OutOfSyncOnly = $false
    )

    process {
        Get-GitRepoStatus @PSBoundParameters | Format-Table -AutoSize -Property @{
            Name = 'Repository'; Expression = { $_.Repository }; Alignment = 'Left'
        }, @{
            Name = 'Status'; Expression = { $_.Status }; Alignment = 'Left'
        }, @{
            Name = 'Ahead'; Expression = { $_.Ahead }; Alignment = 'Right'
        }, @{
            Name = 'Behind'; Expression = { $_.Behind }; Alignment = 'Right'
        }
    }
}

function Get-GitRepoStatusDetails {
    [CmdletBinding()]
    [Alias('grsd')]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path = $(if ($Script:CodePath) { $Script:CodePath } elseif ($global:CodePath) { $global:CodePath } else { $CodePath }),

        [switch]
        $Recurse,

        [switch]
        $OutOfSyncOnly = $false
    )
    Get-GitRepoStatus -Path $Path -Recurse:$Recurse -ShowDetails:$true -OutOfSyncOnly:$OutOfSyncOnly | ForEach-Object {
        # Write-Host "Repository: $($_.Repository) ($($_.Path))" -ForegroundColor Magenta
        Write-Host "$($_.Repository)" -ForegroundColor Magenta -NoNewline
        Write-Host " ($($_.Path))" -ForegroundColor DarkGray -NoNewline
        Write-Host " Status: $($_.Status)" -ForegroundColor $_.StatusColor
        if ($_.Details) {
            Write-Host "Details:`n$($_.Details)" -ForegroundColor Yellow
        }
    }
}

# ensure aliases exist in module scope so they can be exported
Set-Alias -Name gsr  -Value Get-GitRepoStatus       -Scope Local
Set-Alias -Name gsrt -Value Get-GitRepoStatusTable  -Scope Local
Set-Alias -Name gsrd -Value Get-GitRepoStatusDetails -Scope Local

# export functions and aliases
Export-ModuleMember -Function Get-GitRepoStatus, Get-GitRepoStatusTable, Get-GitRepoStatusDetails -Alias gsr, gsrt, gsrd