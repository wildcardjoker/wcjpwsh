<#
.SYNOPSIS
    Open the PSReadLine history file in an editor for manual editing.

.DESCRIPTION
    Locates the PSReadLine history file (common locations are checked) and
    opens it in the user's chosen editor. If no editor is specified the
    function will prefer the Visual Studio Code `code` command if available,
    otherwise it falls back to the default registered editor for .txt files.

.SYNTAX
    Edit-History [-Editor <String>] [-Force] [<CommonParameters>]

.PARAMETER Editor
    Optional. The command (executable) to use to open the history file,
    for example 'code', 'notepad', or a full path to an editor executable. If
    omitted the function will attempt to use 'code' or the system's default
    application for text files.

.PARAMETER Force
    If present, create the history file if it does not already exist.

.EXAMPLE
    Edit-History

    Opens the PSReadLine history file in the preferred editor.

.EXAMPLE
    Edit-History -Editor notepad

    Opens the history file in Notepad.

.NOTES
    - The location of the PSReadLine history file has changed across
      PowerShell versions and Windows/Unix platforms. The function checks a
      set of well-known paths and accepts a manually specified path via the
      -Editor parameter only for the editor executable.
    - Editing the history file while PowerShell is running may not update the
      in-memory history for the current session.
#>

function Edit-History {
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='Default')]
    Param(
        [Parameter(Position=0)]
        [string]
        $Editor,

        [Parameter()]
        [switch]
        $Force
    )

    Begin {
        # Candidate history file locations (Windows and cross-platform paths)
        $candidates = @(
            "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
            "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
            "$env:HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt",
            "$env:HOME/.config/powershell/PSReadLine/ConsoleHost_history.txt"
        ) | Where-Object { $_ -ne $null -and $_ -ne '' }

        $historyPath = $null
        foreach ($p in $candidates) { if (Test-Path -Path $p) { $historyPath = $p; break } }

        if (-not $historyPath) {
            # If none exist yet, choose the first candidate as the path to create if forced
            $historyPath = $candidates[0]
        }

        Write-Verbose "Selected history path: $historyPath"
    }

    Process {
        if (-not (Test-Path -Path $historyPath)) {
            if ($Force) {
                if ($PSCmdlet.ShouldProcess($historyPath, 'Create history file')) {
                    try {
                        New-Item -Path $historyPath -ItemType File -Force | Out-Null
                    } catch {
                        Throw "Failed to create history file at '$historyPath': $_"
                    }
                } else { return }
            } else {
                Throw "History file not found at '$historyPath'. Use -Force to create it."
            }
        }

        # Determine the editor command to run
        $editorCmd = if ($Editor) { $Editor } elseif (Get-Command code -ErrorAction SilentlyContinue) { 'code' } else { $null }

        if ($editorCmd) {
            if ($PSCmdlet.ShouldProcess($historyPath, "Open in $editorCmd")) {
                try { Start-Process -FilePath $editorCmd -ArgumentList $historyPath -NoNewWindow } catch { Throw "Failed to start '$editorCmd' with '$historyPath': $_" }
            }
        } else {
            # Fallback to opening with the default associated application
            if ($PSCmdlet.ShouldProcess($historyPath, 'Open in default editor')) {
                try { Start-Process -FilePath $historyPath } catch { Throw "Failed to open history file '$historyPath': $_" }
            }
        }
    }

    End {
    }
}