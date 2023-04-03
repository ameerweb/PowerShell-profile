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
oh-my-posh init pwsh --config 'C:\Users\ameer\ps_themes\montys.omp.json' | Invoke-Expression

# Alias
New-Alias c clear
New-Alias vim nvim
New-Alias ll ls
New-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
New-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
New-Alias pn pnpm
New-Alias grep findstr

#utitlties 
function which ($command) {
	Get-Command -Name $command -ErrorAction SilentlyContinue |
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
function lh { Get-ChildItem -ah }
function ~ { Set-Location ~ }
function d { Set-Location c:\users\ameer\Desktop }
function dd { Set-Location C:\Users\ameer\Documents\ }
function ip {
	$connection = Test-NetConnection -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	$ip = $connection.SourceAddress.IPAddress
	if ($null -eq $ip -or $ip -eq "") {
		Write-Host "Not Connected"
	}
	else {
		Set-Clipboard -Value $ip
		return $ip
	}
	
}

# another function
function ipw {
	$connection = Get-NetIPAddress | Where-Object { ($_.InterfaceIndex -eq 28) -and ($_.InterfaceAlias -eq 'Wi-Fi') } | Select-Object IPAddress | findstr 192*
	# TODO: try this way later
	#  (Find-NetRoute -RemoteIPAddress 0.0.0.0).IPAddress
	if (-Not $connection) {
		Write-Host "Not Found"
	}
	else {
		Set-Clipboard -Value $connection
		Write-Output "Connectd Ip Address is $connection has copied to clipboard"
	}
}

# Odoo configuration :
function scaffold {
	<#
	This is a simplify for odoo scaffold commands.
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
function pull_odoo {
	<#
	This function is to pull the code uodates from github.
	#>
	param(
		[Parameter()]
		[string]$odoo_version)


	if (($odoo_version -ne "") -and ($null -ne $odoo_version)) {
		Write-Output "================odoo-$odoo_version================"
		git --git-dir=D:\odoo\odoo-$odoo_version\.git pull
	}
	else {
		Write-Output "No odoo version set"
	}
}
function uninstall_odoo {
	<#
	This function is to uninstall odoo module from command becouse there is no officail way in docummentation to do this
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
function fix_odoo {
	<#
	This function is to fix the port if it used by another service
	#>
	#TODO: This function need to be fixed
	param(
		[Parameter()]
		[Int64]$odoo_version)
		
	$port = "80$odoo_version"

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
		Write-Output "There is no process using port (8016) of odoo"
	}
}
function run_odoo {
	<#
	This function is to run odoo directly from command prompt.
	#>
	try {
		if ($args.Length -eq 1) {
			&"D:\odoo\odoo-$args\venv-odoo$args\Scripts\python.exe" D:\odoo\odoo-$args\odoo-bin --c D:\odoo\odoo-$args\odoo.conf
		}
		elseif ($args.Length -gt 1) {
			$odoo_version = $args[0]
			$kwargs = $args[1..($args.Length - 1)]
			&"D:\odoo\odoo-$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" D:\odoo\odoo-$odoo_version\odoo-bin -c D:\odoo\odoo-$odoo_version\odoo.conf $kwargs
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

	$ip = ip;
	$link = "http://" + $ip + ":80$odoo_version"

	Write-Output "the link is ==> $link"
	Set-Clipboard -Value $link
}
