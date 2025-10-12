<#
.SYNOPSIS
    Move up a number of directory levels from the current location.

.DESCRIPTION
    Changes the current location to the Nth parent of the current working
    directory. For example, when invoked with -Nodes 3 the cmdlet will
    change directory to '..\..\..' relative to the current location.

.PARAMETER Nodes
    The number of parent directory levels to traverse. Must be an integer
    greater than or equal to 0. The default is 1.

.INPUTS
    System.Int32

.OUTPUTS
    None. This cmdlet changes the session location and does not return an
    object on success. Errors are written to the error stream.

.EXAMPLE
    Set-LocationUp
    Moves up one directory (equivalent to: cd ..)

.EXAMPLE
    Set-LocationUp -Nodes 3
    Moves up three directories (equivalent to: cd ..\..\..)

.EXAMPLE
    2 | Set-LocationUp
    Demonstrates pipeline usage when the function receives an integer from
    the pipeline.

.NOTES
    - Exports the function as `Set-LocationUp` with an alias `up`.
    - Uses ShouldProcess so callers can preview changes with -WhatIf.
    - Author: Converted and documented by automation.
#>

function Set-LocationUp {
    [Alias('up')]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default')]
    Param (
        # The number of nodes to traverse upwards
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateScript({ $_ -ge 0 })]
        [int]
        $Nodes = 1
    )

    # If caller asked for no movement, do nothing.
    if ($Nodes -le 0) {
        Write-Verbose "Nodes is $Nodes. No location change will be performed."
        return
    }

    # Build the relative path by joining '..' the requested number of times.
    try {
        $parts = for ($i = 0; $i -lt $Nodes; $i++) { '..' }
        $relativePath = $parts -join '\\'
    }
    catch {
        Throw "Failed to build relative path: $_"
    }

    # Use ShouldProcess so callers can use -WhatIf or -Confirm.
    $current = (Get-Location).Path
    $action = "Change location from '$current' to '$relativePath'"
    if ($PSCmdlet.ShouldProcess($current, $action)) {
        try {
            Set-Location -Path $relativePath
        }
        catch {
            Write-Error "Set-Location failed: $_"
        }
    }
}

Export-ModuleMember -Function Set-LocationUp -Alias 'up'