Invoke-Expression (&starship init powershell)
Import-Module Terminal-Icons
Import-Module posh-git
$env:POSH_GIT_ENABLED = $true

# PSReadLine 
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

# oh-my-posh:
oh-my-posh init pwsh --config 'C:\Users\ameer\Documents\PowerShell\montys.omp.json' | Invoke-Expression

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

	if ($tail){
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

function scaffold {
	<#
	This is a simplify for odoo scaffold commands.
	Usage scaffold 16 module_name
	#>
	param(
		[Parameter()]
		[Int64]$odoo_version,
		[Parameter()]
		[string]$module_name)

	try {
		&"D:\odoo\odoo-$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" D:\odoo\odoo-$odoo_version\odoo-bin scaffold $module_name D:\odoo\odoo-$odoo_version\custom-addons
		$folder = "D:\odoo\odoo-$odoo_version\custom-addons\" + $module_name
		if (Test-Path -Path $folder) {
			Write-Host "Module $module_name created seccessfully in odoo v$odoo_version"
		}
	}
	catch {
		Write-Host "Something wentwrong"
	}
	
}

function uninstall_odoo {
	<#
	This function is to uninstall odoo module from command becouse there is no officail way in docummentation to do this.
	Usage: uninstall_odoo 16 db_name module_name
	#>
	# TODO: Future update : use odoorpc may be helpfull.
	param(
		[Parameter(HelpMessage = "odoo version")]
		[Int64]$odoo_version,
		[Parameter()]
		[string]$dbname,
		[Parameter()]
		[string]$module_name)
		

	try {
		&"D:\odoo\odoo-$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" D:\odoo\odoo-$odoo_version\odoo-bin shell -d $dbname --addons-path=D:\odoo\odoo-$odoo_version\custom-addons
		Write-Host "An uninstallation command has copied to clipboard please past it to the python command shell bellow"
		Set-Clipboard "self.env['ir.module.module'].search([('name', '=', '$module_name')]).button_immediate_uninstall()"
	}
	catch {
		Write-Host "Something wentwrong"
	}
	
}
function fix_port {
	<#
	This function is to fix the port if it used by another service, if the port is not used by any service the the Windows NAT Driver (winnat) 
	which is reserve ports for Windows use (even if Windows 10 isn't actually using them) so that no other programs on your computer can use these ports.
	This appeae in windows update 2018.
	Usage: fix_port 8016
	#>
	param(
		[Parameter()]
		[Int64]$port)

	$netstate = netstat -ano | findStr $port
	
	if ($netstate.count -gt 0) {
		foreach ($result in $netstate) {
			$splitArray = $result -split " "
			$procID = $splitArray[$splitArray.length - 1]
			$procName = Get-Process | Where-Object Id -EQ $procID | Select-Object -Expand ProcessName
			Stop-Process $procID -Force -ErrorAction SilentlyContinue
			Write-Output "Process $procName with id $procID is killed"
		}
	}
	else {
		Restart-Service -Name winnat
		Write-Output "There is no process using port (8016) of odoo, Restarting winnat Servise"
	}
}
function run_odoo {
	<#
	This function is to run odoo directly from command prompt.
	Usage: run_odoo 16 
	#>
	try {
		if ($args.Length -eq 1) {
			&"D:\odoo\odoo-$args\venv-odoo$args\Scripts\python.exe" D:\odoo\odoo-$args\odoo-bin --c D:\odoo\odoo-$args\odoo.conf
		}
		elseif ($args.Length -gt 1) {
			$odoo_version = $args[0]
			$kwargs = $args[1..($args.Length - 1)]
			&"D:\odoo\odoo-$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" D:\odoo\odoo-$odoo_version\odoo-bin $kwargs
		}
		else {
			Write-Host "enter the odoo version number followed by any anrguments you wnat"
		}	
	}
	catch {
		Write-Host "Not Fount"
	}
};

function ip_odoo {
	<#
	This function is to get the link to access odoo localy from local network,
	for example if you want to let teammates to test module in your local machine.
	#>
	
	# TODO: Firewall port management if not enabled.
	
	param(
		[Parameter()]
		[Int64]$odoo_version)
	$ipaddress = (Find-NetRoute -RemoteIPAddress 0.0.0.0).IPAddress
	Write-Host $x
	if ($ipaddress) {
		New-NetFirewallRule -DisplayName "Odoo $odoo_version Local" -Profile 'Private' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80$odoo_version | Out-Null
		$link = "http://" + $ipaddress[0] + ":80$odoo_version"
		Write-Output "the link is ==> $link is copied to clipboard"
		Set-Clipboard -Value $link
	}
	else {
		Write-Host "Not Connected"
	}
	
}

#####################################
####    -- Other Setting  --    ####
#####################################

function setIcon() {
	Set-Content -Path 'desktop.ini' -Value @"
[.ShellClassInfo]
ConfirmFileOp=0
NoSharing=0
IconFile=icon.ico
IconIndex=0
FolderType=Videos
"@
	attrib +s +h 'desktop.ini'

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
