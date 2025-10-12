<#
.SYNOPSIS
    Display combinations of console foreground and background colours.

.DESCRIPTION
    Utility to display foreground/background colour combinations supported by
    the hosting console. The cmdlet can either display all combinations, or
    cycle through foregrounds or backgrounds using a single provided colour.

.PARAMETER Background
    When specified, the value provided via -Colour is treated as the
    background colour and the function will cycle the foreground colours.

.PARAMETER Foreground
    When specified, the value provided via -Colour is treated as the
    foreground colour and the function will cycle the background colours.

.PARAMETER Colour
    A single System.ConsoleColor value to be used as either a foreground or
    background colour depending on which switch is supplied. When omitted the
    function will show all foreground/background combinations.

.EXAMPLE
    Show-AllColours
    Displays every foreground/background combination.

.EXAMPLE
    Show-AllColours -Colour Blue -Background
    Uses Blue as the background and cycles the foreground colours.

.EXAMPLE
    Show-AllColours -Colour Yellow -Foreground
    Uses Yellow as the foreground and cycles the background colours.

.NOTES
    - This module writes coloured output to the host using Write-Host. When
      the foreground and background colours are equal the line is suppressed
      to remain readable.
#>

# Helper: show a single foreground/background pair only if readable
function Invoke-ShowColour {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.ConsoleColor]
        $ForegroundColour,

        [Parameter(Mandatory=$true)]
        [System.ConsoleColor]
        $BackgroundColour
    )

    # Only display when foreground and background are different for readability
    if ($ForegroundColour -ne $BackgroundColour) {
        Write-Host "ForegroundColour: $ForegroundColour   BackgroundColour: $BackgroundColour" -ForegroundColor $ForegroundColour -BackgroundColor $BackgroundColour
    }
}

function Show-AllColours {
    [CmdletBinding(DefaultParameterSetName='UseConsoleColour')]
    param(
        # Treat -Colour as the background and cycle foregrounds
        [Parameter(ParameterSetName='Background')]
        [switch]
        $Background,

        # Treat -Colour as the foreground and cycle backgrounds
        [Parameter(ParameterSetName='Foreground')]
        [switch]
        $Foreground,

        # A single colour to use in combination with all others
        [Parameter(ParameterSetName='Background',Mandatory=$true,ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='Foreground',Mandatory=$true,ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='UseConsoleColour',Mandatory=$false,ValueFromPipeline=$true)]
        [System.ConsoleColor]
        $Colour
    )

    begin {
        # Get the available ConsoleColor values once
        $colours = [enum]::GetValues([System.ConsoleColor])
    }
    process {
        if ($Background) {
            Write-Verbose "Using $Colour as background; cycling foreground colours."
            foreach ($fcolour in $colours) {
                Invoke-ShowColour -ForegroundColour $fcolour -BackgroundColour $Colour
            }
        }
        elseif ($Foreground) {
            Write-Verbose "Using $Colour as foreground; cycling background colours."
            foreach ($bcolour in $colours) {
                Invoke-ShowColour -ForegroundColour $Colour -BackgroundColour $bcolour
            }
        }
        elseif ([string]::IsNullOrWhiteSpace($Colour) -eq $true) {
            Write-Verbose "No -Colour supplied; cycling all foreground/background combinations."
            foreach ($bcolour in $colours) {
                foreach ($fcolour in $colours) {
                    Invoke-ShowColour -ForegroundColour $fcolour -BackgroundColour $bcolour
                }
            }
        }
        else {
            Write-Verbose "Single -Colour supplied without -Foreground/-Background; show that colour paired with all others."
            foreach ($bcolour in $colours) {
                Invoke-ShowColour -ForegroundColour $Colour -BackgroundColour $bcolour
            }
            foreach ($fcolour in $colours) {
                Invoke-ShowColour -ForegroundColour $fcolour -BackgroundColour $Colour
            }
        }
    }
    end {}
}

Export-ModuleMember -Function Show-AllColours