# PowerShell Profile Setup

## 1. Install Oh-My-Posh

Install Oh-My-Posh using winget:

```powershell
winget install JanDeDobbeleer.OhMyPosh --source winget
```

To upgrade Oh-My-Posh in the future:

```powershell
winget upgrade JanDeDobbeleer.OhMyPosh --source winget
```

## 2. Configure Execution Policy

PowerShell blocks running local scripts by default. To allow local scripts to run (while requiring remote scripts to be signed), run the following command:

```powershell
Set-ExecutionPolicy RemoteSigned
```

## 3. Install Fonts

You need a Nerd Font for icons to render correctly.

**Option A: Automatic Installation (Recommended)**
Run the following command as Administrator:

```powershell
oh-my-posh font install meslo
```
This will install the Meslo Nerd Font globally.

**Option B: Manual Installation**
Download and install a font from [Nerd Fonts](https://www.nerdfonts.com/).

## 4. Install Terminal Icons

To show icons for directories and files in directory listings:

1.  Install the module (Run as Administrator):
    ```powershell
    Install-Module -Name Terminal-Icons -Repository PSGallery
    ```

2.  Add the following line to your PowerShell profile (`$profile`):
    ```powershell
    Import-Module Terminal-Icons
    ```

## 5. Install PSReadLine

To enable advanced command-line editing features:

```powershell
Install-Module PSReadline --Force
```
