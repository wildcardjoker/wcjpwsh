<#
.Synopsis
    Open the PSReadline History file to allow user to edit.
.DESCRIPTION
    Open the PSReadline History.txt file in a text editor, in order for user to edit the history.
.INPUTS
    None
.OUTPUTS
    None
.EXAMPLE
    Edit-History

    Open the History.txt file in a text editor.
#>

function Edit-History {
    [Alias('')]
    [CmdletBinding(
        SupportsShouldProcess=$false,
        DefaultParameterSetName='Default')]
    Param()

    # Code executes from here

    # Setup
    Begin{
        
    } # Begin


    Process{
        code $env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
    } # Process

    # Clean up
    End{
    
    } # End
}