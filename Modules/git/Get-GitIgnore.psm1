<#
.SYNOPSIS
    Downloads a .gitignore file template from GitHub's gitignore repository.

.DESCRIPTION
    This function downloads a .gitignore template file from GitHub's official
    gitignore repository (https://github.com/github/gitignore) to the current
    directory. It defaults to downloading the Visual Studio template but can
    download any available template by specifying its name.
    
    After downloading, if Git is available, the function will automatically:
    - Add the .gitignore file to the Git staging area
    - Commit the file with the message 'Add .gitignore.'
    - Push the commit to the remote repository

.PARAMETER Name
    The name of the .gitignore template to download. This should match a file
    in the GitHub gitignore repository. The '.gitignore' extension is optional.
    Common templates include: VisualStudio, Node, Python, Java, Go, etc.
    
    Default: 'VisualStudio'

.EXAMPLE
    Get-GitIgnore
    Downloads the Visual Studio .gitignore template to the current directory.

.EXAMPLE
    Get-GitIgnore -Name "Node"
    Downloads the Node.js .gitignore template.

.EXAMPLE
    Get-GitIgnore -Name "Python.gitignore"
    Downloads the Python .gitignore template (extension is optional).

.EXAMPLE
    Get-GitIgnore "Java"
    Downloads the Java .gitignore template using positional parameter.

.INPUTS
    String - The name of the gitignore template to download.

.OUTPUTS
    None - Downloads file to disk and optionally commits to Git.

.NOTES
    - Credit: Based on https://gist.github.com/motowilliams/8191936
    - Requires internet connection to download from GitHub
    - If Git is not available, the file is downloaded but not committed
    - The downloaded file will overwrite any existing .gitignore in the current directory
    - Available templates can be viewed at: https://github.com/github/gitignore

.LINK
    https://github.com/github/gitignore

.FUNCTIONALITY
    Git, Repository Management, File Download
#>
Function Get-GitIgnore {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Name
    )

    # Use default template name if none provided
    $nameArg   = $Name ?? 'VisualStudio'
    
    # Ensure filename has .gitignore extension
    $fileName  = ($nameArg -match '\.gitignore$') ? $nameArg : "$nameArg.gitignore"
    
    # Construct URL to GitHub's raw gitignore file
    $url       = "https://raw.githubusercontent.com/github/gitignore/master/$fileName"
    
    # Set destination path to .gitignore in current directory
    $destPath  = Join-Path ($PWD?.Path ?? '.') '.gitignore'

    Write-Host "Downloading $url to $destPath"
    
    # Download the file using WebClient
    try {
        (New-Object System.Net.WebClient).DownloadFile($url, $destPath)
    }
    catch {
        Write-Error "Failed to download .gitignore template. Please check the template name and internet connection."
        Write-Error "Available templates: https://github.com/github/gitignore"
        return
    }

    # If Git is available, add, commit, and push the .gitignore file
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            git add $destPath
            git commit -m 'Add .gitignore.'
            Write-Host "Successfully committed .gitignore file." -ForegroundColor Green
        }
        catch {
            Write-Warning "Git operations failed. .gitignore downloaded to $destPath but not committed."
        }
    } else {
        Write-Warning "Git not found. .gitignore downloaded to $destPath"
    }
}
Export-ModuleMember -Function Get-GitIgnore