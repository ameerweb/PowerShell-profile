Invoke-Expression (&starship init powershell)
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt Parado

# Alias
New-Alias c clear
New-Alias vim nvim
New-Alias ll ls

# name an welcoming 
$usr = (Get-ChildItem Env:\USERNAME).value
$time = Get-Date -Format "HH:mm"
$date = Get-Date -Format "dd-MM-yyyy"

Clear-Host
Write-Output "PowerShell 7.3.2"
Write-Output "Hi $usr its $time ---- date is: $date"

function run_odoo16 {
	&"D:\odoo\odoo-16\venv-odoo16\Scripts\python.exe" D:\odoo\odoo-16\odoo-bin -c D:\odoo\odoo-16\odoo.conf
};
function run_odoo15 {
	&"D:\odoo\odoo-15\venv-odoo15\Scripts\python.exe" D:\odoo\odoo-15\odoo-bin -c D:\odoo\odoo-15\odoo.conf
};
function run_odoo14 {
	&"D:\odoo\odoo-14\venv-odoo14\Scripts\python.exe" D:\odoo\odoo-14\odoo-bin -c D:\odoo\odoo-14\odoo.conf
};
function run_odoo11 {
	&"D:\odoo\odoo-11\venv-odoo11\Scripts\python.exe" D:\odoo\odoo-11\odoo-bin -c D:\odoo\odoo-11\odoo.conf
};
function run_odoo-master {
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
