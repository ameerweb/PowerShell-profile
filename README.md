# PowerShell profile

Personal configuration for **PowerShell 7 on Windows**: the `montys.omp.json`
prompt, Terminal-Icons, Emacs key bindings, history suggestions, aliases and
Odoo helpers. Installed modules, downloaded help, caches and editor backups
are intentionally excluded from Git.

## Set up a new Windows device

### 1. Install applications

Run in a Windows terminal. If `winget` is missing, install/update Microsoft's
[App Installer](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
Accept installer elevation prompts if requested.

```powershell
winget install --id Microsoft.PowerShell --exact --source winget
winget install --id Git.Git --exact --source winget
winget install --id JanDeDobbeleer.OhMyPosh --exact --source winget
```

Optionally install Windows Terminal if it is not already present:

```powershell
winget install --id Microsoft.WindowsTerminal --exact --source winget
```

Close and reopen the terminal so PATH is refreshed. Start **PowerShell 7**
(`pwsh`), not Windows PowerShell 5.1. Run the remaining commands in PowerShell 7.

Official instructions: [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows),
[Git for Windows](https://git-scm.com/install/windows),
[Oh My Posh](https://ohmyposh.dev/docs/installation/windows).

### 2. Clone the configuration

For a new device where the PowerShell profile directory is absent or empty:

```powershell
$profileDirectory = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
git clone https://github.com/ameerweb/PowerShell-profile.git $profileDirectory
if ($LASTEXITCODE -ne 0) { throw 'Clone failed; use the existing-directory option below.' }
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Using `$PROFILE` handles a redirected Documents folder (for example OneDrive)
and different Windows usernames. This execution policy permits local scripts
and requires downloaded scripts to be signed or explicitly unblocked; an
organization's Group Policy can override it.

**If the directory already contains files:** keep them and clone elsewhere.
The following creates a small loader and saves an existing profile first:

```powershell
$profileRepository = Join-Path $HOME 'source\PowerShell-profile'
git clone https://github.com/ameerweb/PowerShell-profile.git $profileRepository
if ($LASTEXITCODE -ne 0) { throw 'Clone failed; check the destination before continuing.' }
$profilePath = $PROFILE.CurrentUserCurrentHost
New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force | Out-Null
if (Test-Path -LiteralPath $profilePath) {
    Copy-Item -LiteralPath $profilePath -Destination "$profilePath.$(Get-Date -Format yyyyMMddHHmmssfff).bak" -ErrorAction Stop
}
$entryPoint = (Join-Path $profileRepository 'Microsoft.PowerShell_profile.ps1').Replace("'", "''")
Set-Content -LiteralPath $profilePath -Value ". '$entryPoint'" -Encoding utf8
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

With the loader option, the repository's `powershell.config.json` is not in
PowerShell's configuration directory. It is optional; the profile does not
depend on its experimental-feature settings. Review those settings against
your installed PowerShell version before copying that file beside `$PROFILE`.

### 3. Install the modules

Use the official PowerShell Gallery; current-user installs need no administrator
shell. Approve the PSGallery repository prompt if shown.

```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
```

PowerShell 7 includes PSReadLine. To install/update the Gallery version, first
start a clean shell so the existing module is not in use:

```powershell
pwsh -NoProfile -NonInteractive -Command "Install-Module -Name PSReadLine -Repository PSGallery -Scope CurrentUser -Force"
```

The profile already imports these modules in interactive terminals. Do not add
duplicate initialization lines. Sources: [Terminal-Icons](https://github.com/devblackops/Terminal-Icons),
[PSReadLine installation](https://learn.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline).

### 4. Install and select a Nerd Font

```powershell
oh-my-posh font install meslo
```

In Windows Terminal, open Settings > your PowerShell profile > Appearance >
Font face and select the installed Meslo Nerd Font. Restart the terminal.
See [Oh My Posh font setup](https://ohmyposh.dev/docs/installation/fonts).

### 5. Check the result

Open a fresh PowerShell 7 tab. The custom prompt, file icons, Emacs editing and
history predictions should work. Reload after configuration edits with:

```powershell
. $PROFILE
```

An automated command should emit only `profile-ok`, without prediction errors:

```powershell
pwsh -NoLogo -NonInteractive -Command "Write-Output 'profile-ok'"
```

## Other packages previously stored in this repository

These are **optional**; the profile does not import them at startup. Install
only the tools you use. This table covers the packages removed from Git,
including the old `z` files that were under a Terminal-Icons version folder.

| Package | Official installation / replacement |
| --- | --- |
| PSReadLine | Included in PowerShell 7; Gallery update command above. |
| Terminal-Icons | Gallery command above. |
| oh-my-posh PowerShell module | Replaced by the WinGet executable above; do not reinstall the legacy module. See [migration](https://ohmyposh.dev/docs/migrating). |
| posh-git | `Install-Module posh-git -Repository PSGallery -Scope CurrentUser` ([project](https://github.com/dahlbyk/posh-git)). |
| PSFzf | `winget install --id junegunn.fzf --exact --source winget`, then `Install-Module PSFzf -Repository PSGallery -Scope CurrentUser` ([PSFzf](https://github.com/kelleyma49/PSFzf), [fzf](https://github.com/junegunn/fzf)). |
| Microsoft.WinGet.Client | `Install-Module Microsoft.WinGet.Client -Repository PSGallery -Scope CurrentUser` ([Microsoft instructions](https://learn.microsoft.com/en-us/windows/package-manager/winget/)). This module is separate from the `winget.exe` CLI. |
| z | `Install-Module z -Repository PSGallery -Scope CurrentUser` ([project](https://github.com/badmotorfinger/z)). |

Import an optional module manually when needed (`Import-Module posh-git`,
`Import-Module PSFzf`, or `Import-Module z`). To enable it automatically, add its
import after the profile's interactive-session guard. Oh My Posh already shows
the Git branch; posh-git is not required for that display.

Other aliases/helpers depend on separately installed tools:

- `vim` uses Neovim (`winget install --id Neovim.Neovim --exact --source winget`).
- `tig` and `less` use the standard `C:\Program Files\Git\usr\bin` installation;
  adjust their paths if Git is installed elsewhere.
- `pn` uses [pnpm](https://pnpm.io/installation).
- `wls` opens an already configured Debian WSL distribution.
- `python3.9` is retained only when that legacy Store executable exists. It is
  not required for this profile and is not installed by these instructions.
- The Odoo helpers retain the existing `C:\odoo\odoo{version}` layout and need
  a separate Odoo/Python installation. Cloning this profile does not install Odoo.
- Chocolatey's profile helpers load only if Chocolatey is already installed.

## Startup behavior and local configuration

Aliases and utility/Odoo function definitions are available in automated shells.
Terminal-Icons, PSReadLine settings, Chocolatey integration and Oh My Posh load
only in an interactive ConsoleHost with virtual-terminal support and attached
input/output. `-Command`, `-File`, `-EncodedCommand`, and `-NonInteractive` launches
skip this terminal customization. `pwsh -NoProfile` skips the entire profile.

Prompt setup uses the [official Oh My Posh initialization](https://ohmyposh.dev/docs/installation/prompt)
and its own cache. The old repository-local `omp_init.ps1` is no longer read.
Theme and helper paths are relative to the cloned profile, not a username.

Optional personal variables can be stored as a JSON object in
`config.local.json` beside the cloned profile. It is ignored by Git. If absent,
the existing `Documents\MEGAsync\Powershell\config.json` location is still checked.
Copy this local configuration separately when moving to another device.

## Updates and Git housekeeping

Run these deliberately, not on every shell startup:

```powershell
winget upgrade --id JanDeDobbeleer.OhMyPosh --exact --source winget
Update-Module -Name Terminal-Icons
# If the Gallery version was installed:
pwsh -NoProfile -NonInteractive -Command "Update-Module -Name PSReadLine"
```

Use `git pull` in the cloned repository to update configuration. Commit changes
to the profile, theme and helper source files. `Modules/`, `Help/`, `Scripts/`,
local JSON, prompt cache and editor backups are ignored.

Downloaded help can be refreshed separately with
`Update-Help -Scope CurrentUser`; it does not belong in Git. Some modules may
not provide downloadable help.

The cleanup removes installed files from Git's index while preserving the
files on this device. It does not erase old commits or reduce historical clone
size. After the cleanup is committed and pushed, new clones use the installation
commands above instead of receiving bundled modules. On another existing clone,
pulling that cleanup may remove formerly tracked packages from disk; reinstall
them using the commands above.
