Import-Module Terminal-Icons

# PSReadLine 
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

# oh-my-posh configuration with caching
$omp_config = 'C:\Users\ameer\Documents\PowerShell\montys.omp.json'
$omp_cache = 'C:\Users\ameer\Documents\PowerShell\omp_init.ps1'

if (Test-Path $omp_config) {
	$omp_bin = (Get-Command oh-my-posh -ErrorAction SilentlyContinue | Select-Object -First 1).Source
	$cache_valid = (Test-Path $omp_cache) -and (Get-Item $omp_cache).LastWriteTime -gt (Get-Item $omp_config).LastWriteTime
    
	if ($omp_bin -and $cache_valid) {
		$cache_valid = (Get-Item $omp_cache).LastWriteTime -gt (Get-Item $omp_bin).LastWriteTime
	}

	if ($cache_valid) {
		. $omp_cache
	}
	else {
		# Generate init script and cache it
		oh-my-posh init pwsh --config $omp_config --print | Set-Content $omp_cache
		. $omp_cache
	}
}
else {
	Write-Warning "Oh-My-Posh config not found at $omp_config"
}

####################################
#########  --   Alias  --  #########
####################################
New-Alias c clear
New-Alias vim nvim
New-Alias ll ls
New-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
New-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
New-Alias pn pnpm
New-Alias grep findstr
New-Alias wls Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Debian
New-Alias python3.9 C:\Users\ameer\AppData\Local\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\python.exe

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
function d { Set-Location c:\users\ameer\Desktop }
function dd { Set-Location C:\Users\ameer\Documents\ }

####################################
####    --  CONFIG FILE  --    #####
####################################
$configFile = "C:\Users\ameer\Documents\MEGAsync\Powershell\config.json"

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

		New-Variable -Name $propertyName -Value $propertyValue -Scope Global
	}
}

#########################################
####    -- Odoo configuration  --    ####
#########################################

# Auto-load Odoo functions
$odooFunctionsPath = Join-Path $HOME "Documents\PowerShell\OdooFunctions.ps1"
if (Test-Path $odooFunctionsPath) {
	. $odooFunctionsPath
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}
function Remove-PyCache {
	param (
		[string]$Path = (Get-Location)
	)

	Get-ChildItem -Path $Path -Directory -Filter '__pycache__' -Recurse | ForEach-Object {
		Remove-Item $_.FullName -Recurse -Force
	}
}
