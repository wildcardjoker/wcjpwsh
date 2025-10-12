<#
.Synopsis
    List the $ENV:PATH variable in user-friendly format
.DESCRIPTION
    Split the $ENV:PATH variable on semicolon and display the results
.INPUTS
    None
.OUTPUTS
    The $ENV:PATH variable, one entry per line
.EXAMPLE
    Get-PathVariable

    List the paths in the $ENV:PATH variable
#>

function Get-PathVariable {
    [Alias('')]
    [CmdletBinding()]
    Param()

    # Code executes from here
    $env:Path -split ';'
}