<#
.SYNOPSIS
    Replace spaces in a filename with a specified character.

.DESCRIPTION
    This module provides a function to rename files by replacing spaces in their names with a specified character.
    It is designed for use in file management tasks, particularly in scenarios where spaces in filenames may cause issues.
    The intended audience includes system administrators and users who need to manage files in a more predictable manner.

.MODULEVERSION
    1.0.0

.AUTHOR
    WildcardJoker

.COMPANYNAME
    WildcardJoker

.COPYRIGHT
    Copyright (c) 2025 WildcardJoker. All rights reserved.

.REQUIREDMODULES
    None

.REQUIREDSCRIPTS
    None

.EXPORTEDFUNCTIONS
    Rename-NoSpaces - Replaces spaces in a filename with a specified character

.EXPORTEDVARIABLES
    None

.EXPORTEDALIASES
    sr - Alias for Rename-NoSpaces

.INPUTS
    [string] $FileName - The name of the file to rename
    [string] $OriginalCharacter - The character to replace (default is space)
    [string] $ReplacementCharacter - The character to replace with (default is underscore)

.OUTPUTS
    [string] - The new name of the file after renaming

.EXAMPLE
    # Basic usage
    Import-Module General-Functions
    Rename-NoSpaces -FileName "My File.txt"
    Get-Item -Path "My_File.txt"

.EXAMPLE
    # Advanced usage with piping and filters
    Get-ChildItem -Path "C:\My Folder" | Where-Object { $_.Extension -eq '.txt' } | Rename-NoSpaces -OriginalCharacter " " -ReplacementCharacter "-"
    Get-ChildItem -Path "C:\My Folder" | Where-Object { $_.Extension -eq '.txt' }

.NOTES
    File Name  : Rename-NoSpaces.psm1
    Author     : WildcardJoker
    Version    : 1.0.0
    Date       : 2025-10-01
    Purpose    : Replace spaces in filenames with a specified character.

.LINK
    <URL to full documentation, repository, changelog, or issue tracker>

#>
function Rename-NoSpaces()
{
    [CmdletBinding()]
    [Alias('sr')]
    Param(
        # File to rename
        [Parameter()]
        [string]
        $FileName,

        # Character to be replaced
        [Parameter()]
        [string]
        $OriginalCharacter = " ",

        # Replacement Character
        [Parameter()]
        [string]
        $ReplacementCharacter = "_"
    )

    [string] $leaf = (Split-Path -Path $Filename -Leaf)
    [string] $RenamedFile = ($FileName -replace $leaf, $($leaf -replace $OriginalCharacter, $ReplacementCharacter))
    Write-Verbose "Rename $Filename to $RenamedFile"
    Move-Item $FileName $RenamedFile
}

Export-ModuleMember -Function Rename-NoSpaces -Alias 'sr'