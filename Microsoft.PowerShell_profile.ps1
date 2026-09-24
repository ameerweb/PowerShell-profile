# PowerShell 7 profile. Helpers remain available to scripts and coding agents.
# Terminal-only features below are skipped for redirected and command sessions.
####################################
#########  --   Alias  --  #########
####################################
Set-Alias c clear
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias pn pnpm
Set-Alias grep findstr
function wls { Set-Location -LiteralPath '\\wsl.localhost\Debian' }
$legacyPython = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\python.exe'
if (Test-Path -LiteralPath $legacyPython -PathType Leaf) {
    Set-Alias python3.9 $legacyPython
}

####################################
########  --  Utitlties  --  #######
####################################
function gcg { git config --global @args }
function gcl { git config --local @args }

function which ($command) {
	Get-Command -Name $command -ErrorAction SilentlyContinue |
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
function tail {
	<#Unix equivalent Tail command#>
	param (
		
		[Parameter(Mandatory = $false)]
		[ValidateNotNullOrEmpty()]
		[String]$tail,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$path
	)

	if ($tail) {
		Get-Content $path -Tail ([Math]::Abs($tail))
	}
	else {
		Get-Content $path
	}
}
function lh { Get-ChildItem -ah }
function ~ { Set-Location ~ }
function d { Set-Location -LiteralPath ([Environment]::GetFolderPath('Desktop')) }
function dd { Set-Location -LiteralPath ([Environment]::GetFolderPath('MyDocuments')) }

####################################
####    --  CONFIG FILE  --    #####
####################################
# Prefer an ignored, device-local file; retain the existing MEGAsync fallback.
$configFile = Join-Path $PSScriptRoot 'config.local.json'
$legacyConfigFile = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'MEGAsync\Powershell\config.json'
if (-not (Test-Path -LiteralPath $configFile) -and (Test-Path -LiteralPath $legacyConfigFile)) {
    $configFile = $legacyConfigFile
}

<#
This Function is used to add any custom key value to $configFile key value, So i can permanent save them to use them later.
usage: Add-Config -key 'key1' -value "Any Value" 
#>
function Add-Config {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$Key,

		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$Value
	)

	if (Test-Path -Path $configFile -PathType Leaf) {
		# Read the JSON content
		try {
			$jsonContent = Get-Content $configFile | Out-String | ConvertFrom-Json
			$jsonContent | Add-Member -Type NoteProperty -Name $Key -Value $Value
			$jsonContent | ConvertTo-Json | Set-Content $configFile
		}
		catch {
			Write-Error "Error reading JSON file: $($_.Exception.Message)"
			exit 1
		}
	}
	else {
		Write-Host "No JSON File Found"
	}
}

# loop throug all properties in json file to load them all to powershell
if (Test-Path $configFile) {
	$config = Get-Content -Path $configFile -Raw | ConvertFrom-Json

	foreach ($property in $config.PSObject.Properties) {
		$propertyName = $property.Name
		$propertyValue = $property.Value

		Set-Variable -Name $propertyName -Value $propertyValue -Scope Global
	}
}

#########################################
####    -- Odoo configuration  --    ####
#########################################

# Auto-load Odoo functions
$odooFunctionsPath = Join-Path $PSScriptRoot 'OdooFunctions.ps1'
if (Test-Path $odooFunctionsPath) {
	. $odooFunctionsPath
}

function Remove-PyCache {
	param (
		[string]$Path = (Get-Location)
	)

	Get-ChildItem -Path $Path -Directory -Filter '__pycache__' -Recurse | ForEach-Object {
		Remove-Item $_.FullName -Recurse -Force
	}
}

# Only initialize prompt decoration and keyboard editing in an interactive VT
# console. -Command/-File sessions can have a TTY too, so check launch arguments.
$profileCommandSession = [Environment]::GetCommandLineArgs() | Where-Object {
    $_ -match '^-(noni|c(?:o|$)|f(?:i|$)|e(?:c|n|$))'
}
$profileInteractive = $Host.Name -eq 'ConsoleHost' -and
    $Host.UI.SupportsVirtualTerminal -and
    -not [Console]::IsOutputRedirected -and
    -not [Console]::IsInputRedirected -and
    -not $profileCommandSession

if (-not $profileInteractive) { return }

# Optional modules: a fresh clone still starts before setup is completed.
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs -BellStyle None
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    # PredictionSource was introduced in PSReadLine 2.1.
    if ((Get-Command Set-PSReadLineOption).Parameters.ContainsKey('PredictionSource')) {
        Set-PSReadLineOption -PredictionSource History
    }
}

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

if ($env:ChocolateyInstall) {
    $ChocolateyProfile = Join-Path $env:ChocolateyInstall 'helpers\chocolateyProfile.psm1'
    if (Test-Path -LiteralPath $ChocolateyProfile -PathType Leaf) {
        Import-Module $ChocolateyProfile
    }
}

# Use the executable's own initialization/cache. The old omp_init.ps1 wrapper
# stored an absolute path and session ID, and could outlive its generated script.
$ompConfig = Join-Path $PSScriptRoot 'montys.omp.json'
$ompCommand = Get-Command oh-my-posh -CommandType Application -ErrorAction SilentlyContinue
if ($ompCommand -and (Test-Path -LiteralPath $ompConfig -PathType Leaf)) {
    & $ompCommand.Source init pwsh --config $ompConfig | Invoke-Expression
}
