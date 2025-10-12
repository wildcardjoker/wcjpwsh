<#
.SYNOPSIS
    Get a random BOFH excuse from a public list.

.DESCRIPTION
    Downloads a list of classic BOFH (Bastard Operator From Hell) excuses and
    returns one randomly selected line. The function supports a configurable
    source URI, a local fallback file, a request timeout, and an optional in-
    module cache to avoid repeated downloads.

.SYNTAX
    Get-Excuse [[-Uri] <String>] [[-TimeoutSec] <Int32>] [-LocalFallback <String>] [-UseCache] [<CommonParameters>]

.PARAMETER Uri
    The web address that contains the excuse list. Defaults to the original
    UW-Madison page used historically for BOFH excuses.

.PARAMETER TimeoutSec
    How many seconds to wait for the web request before timing out. Default is 10.

.PARAMETER LocalFallback
    Path to a local text file containing excuses (one per line). If the web
    request fails and this file exists, its contents will be used as a fallback.

.PARAMETER UseCache
    If specified the retrieved list will be cached in the module script scope
    for subsequent calls during the same session to reduce network requests.

.EXAMPLE
    Get-Excuse

    Returns a random excuse from the default online source.

.EXAMPLE
    Get-Excuse -LocalFallback C:\tools\excuses.txt

    Use a local file if the network source is unavailable.

.OUTPUTS
    System.String

.NOTES
    - Network calls may fail; use `-LocalFallback` or `-UseCache` to improve
      reliability in scripted scenarios.
#>

Function Get-Excuse {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)]
        [string]
        $Uri = 'http://pages.cs.wisc.edu/~ballard/bofh/excuses',

        [int]
        $TimeoutSec = 10,

        [string]
        $LocalFallback,

        [switch]
        $UseCache
    )

    Begin {
        $cacheVarName = 'Get-Excuse::Cache'
    }

    Process {
        # Try cache first if requested
        if ($UseCache -and (Get-Variable -Name $cacheVarName -Scope Script -ErrorAction SilentlyContinue)) {
            $lines = (Get-Variable -Name $cacheVarName -Scope Script -ErrorAction SilentlyContinue).Value
        } else {
            try {
                # Prefer Invoke-RestMethod for plain content; fall back to Invoke-WebRequest if needed
                if (Get-Command Invoke-RestMethod -ErrorAction SilentlyContinue) {
                    $content = Invoke-RestMethod -Uri $Uri -TimeoutSec $TimeoutSec -ErrorAction Stop
                } else {
                    $content = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop).Content
                }

                # Split into lines and trim carriage returns
                $lines = ($content -split "\n") | ForEach-Object { $_.TrimEnd("`r") } | Where-Object { $_ -ne '' }

                if ($UseCache) { Set-Variable -Name $cacheVarName -Value $lines -Scope Script -Force }
            } catch {
                # If a fallback file is provided and exists, use it
                if ($LocalFallback -and (Test-Path -Path $LocalFallback -PathType Leaf)) {
                    $lines = Get-Content -Path $LocalFallback -ErrorAction Stop | Where-Object { $_ -ne '' }
                } else {
                    Throw "Failed to retrieve excuses from '$Uri' and no valid local fallback provided. $_"
                }
            }
        }

        if (-not $lines -or $lines.Count -eq 0) { return }

        $index = Get-Random -Maximum $lines.Count
        return $lines[$index]
    }
}

Export-ModuleMember -Function Get-Excuse