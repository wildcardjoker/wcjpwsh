# WildCardJoker's PowerShell scripts ⚡️

![PowerShell](https://img.shields.io/badge/PowerShell-ps-blue)
![Module Count](https://img.shields.io/badge/modules-3-brightgreen)

A collection of PowerShell helper modules and scripts that I've found useful.

## Modules 📦

This repository exposes a few focused modules under the `Modules/` folder. Import the module manifest (PSD1 file) or the folder to access the exported functions.

- 🛠️ `General-Functions` — small, handy utilities for everyday PowerShell tasks
  - Notable functions: `Add-PathFolder`, `Edit-History`, `Get-Excuse`, `Get-PathVariable`, `Rename-NoSpaces`, `Set-LocationUp`, `Show-AllColours`, `Update-Profile`
  - Example: `Import-Module .\Modules\General-Functions\General-Functions.psd1`

- 🔧 `git` — git-related helpers
  - Notable functions: `Get-GitIgnore`, `Get-GitRepoStatus`
  - Example: `Import-Module .\Modules\git\git.psd1`

- 🎨 `omp` — helpers for Oh-My-Posh theme management
  - Notable functions: `Add-PoshTheme`, `Set-CustomPoshPrompt`
  - Example: `Import-Module .\Modules\omp\omp.psd1`

## Quick usage examples

Import the `omp` module and list its commands:

```powershell
Import-Module .\Modules\omp\omp.psd1
Get-Command -Module omp
```

Add a theme to your PoshThemes directory:

```powershell
Add-PoshTheme -Source C:\Themes\mytheme.omp.json
```

Edit your PSReadLine history:

```powershell
Import-Module .\Modules\General-Functions\General-Functions.psd1
Edit-History
```

## Contributing

If you'd like to add a utility or improve an existing one, open a PR. Keep functions small and focused, export only what the module should expose, and include tests where appropriate.

---

Happy scripting! 🪄
