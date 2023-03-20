Invoke-Expression (&starship init powershell)
Import-Module Terminal-Icons
Import-Module posh-git
# Set-Theme Paradox
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
$env:POSH_GIT_ENABLED = $true
oh-my-posh --init --shell pwsh --config 'C:\Users\ameer\ps_themes\custom\montys.omp.json' | Invoke-Expression

# PSReadLine 
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

oh-my-posh init pwsh --config 'C:\Users\ameer\ps_themes\montys.omp.json' | Invoke-Expression

# Alias
New-Alias c clear
New-Alias vim nvim
New-Alias ll ls
New-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
New-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
New-Alias pn pnpm

#utitlties 
function which ($command) {
	Get-Command -Name $command -ErrorAction SilentlyContinue |
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# name an welcoming 
# $usr = (Get-ChildItem Env:\USERNAME).value
# $time = Get-Date -Format "HH:mm"
# $date = Get-Date -Format "dd-MM-yyyy"

#Clear-Host
# Write-Output "PowerShell 7.3.2"
# Write-Output "Hi $usr its $time ---- date is: $date"
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
		Write-Output "Connectd Ip Address is $ip has copied to clipboard"
	}
	
}
function run_odoo16 {
	&"D:\odoo\odoo-16\venv-odoo16\Scripts\python.exe" D:\odoo\odoo-16\odoo-bin -c D:\odoo\odoo-16\odoo.conf $args
};
function run_odoo16sh {
	&"D:\odoo\odoo-16\venv-odoo16\Scripts\python.exe" D:\odoo\odoo-16\odoo-bin shell
};
function run_odoo15 {
	&"D:\odoo\odoo-15\venv-odoo15\Scripts\python.exe" D:\odoo\odoo-15\odoo-bin -c D:\odoo\odoo-15\odoo.conf $args
};
function run_odoo14 {
	&"D:\odoo\odoo-14\venv-odoo14\Scripts\python.exe" D:\odoo\odoo-14\odoo-bin -c D:\odoo\odoo-14\odoo.conf $args
};
function run_odoo11 {
	&"D:\odoo\odoo-11\venv-odoo11\Scripts\python.exe" D:\odoo\odoo-11\odoo-bin -c D:\odoo\odoo-11\odoo.conf $args
};
function run_odoo_master {
	&"D:\odoo\odoo-master\venv-odoomaster\Scripts\python.exe" D:\odoo\odoo-master\odoo-bin -c D:\odoo\odoo-master\odoo.conf
}
function fix_odoo16_port {
	$netstate = netstat -ano | findStr "8016"
	
	if ($netstate.count -gt 0) {
		foreach ($result in $netstate) {
			$splitArray = $result -split " "
			$procID = $splitArray[$splitArray.length - 1]
			$procName = Get-Process | Where-Object Id -EQ $procID | Select-Object -Expand ProcessName
			Stop-Process $procID
			Write-Output "Process $procName with id $procID is killed"
		}
	}
	else {
		Write-Output "There is no process using port (8016) of odoo"
	}
}


function pull_odoo_11 {
	Write-Output "================odoo-11================" -ForegroundColor cyan
	git --git-dir=D:\odoo\odoo-11\.git pull
}
function pull_odoo_12 {
	Write-Output "================odoo-12================"
	git --git-dir=D:\odoo\odoo-12\.git pull
}
function pull_odoo_13 {
	Write-Output "================odoo-13================"
	git --git-dir=D:\odoo\odoo-13\.git pull
}
function pull_odoo_14 {
	Write-Output "================odoo-14================"
	git --git-dir=D:\odoo\odoo-14\.git pull
}
function pull_odoo_15 {
	Write-Output "================odoo-15================"
	git --git-dir=D:\odoo\odoo-15\.git pull
}
function pull_odoo_16 {
	Write-Output "================odoo-16================"
	git --git-dir=D:\odoo\odoo-16\.git pull
}
function pull_odoo_master {
	Write-Output "================odoo-master================"
	git --git-dir=D:\odoo\odoo-master\.git pull
}
function pull_odoo_all {
	$connection = Test-NetConnection -WarningAction SilentlyContinue
	if ($connection.PingSucceeded) {

		pull_odoo_11;
	
		pull_odoo_12;
	
		pull_odoo_13;
	
		pull_odoo_14;
	
		pull_odoo_15;
	
		pull_odoo_16;
	
		pull_odoo_master;
	}
	else {
		Write-Output "Please Check Your Internet Connection"
	}
}
