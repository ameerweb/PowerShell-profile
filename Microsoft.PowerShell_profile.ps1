Invoke-Expression (&starship init powershell)
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt Parado

# Alias
New-Alias c clear
New-Alias vim nvim
New-Alias ll ls

function run_odoo16{
	&"D:\odoo\odoo-16\venv-odoo16\Scripts\python.exe" D:\odoo\odoo-16\odoo-bin -c D:\odoo\odoo-16\odoo.conf
	};
function run_odoo15{
	&"D:\odoo\odoo-15\venv-odoo15\Scripts\python.exe" D:\odoo\odoo-15\odoo-bin -c D:\odoo\odoo-15\odoo.conf
	};
function run_odoo14{
	&"D:\odoo\odoo-14\venv-odoo14\Scripts\python.exe" D:\odoo\odoo-14\odoo-bin -c D:\odoo\odoo-14\odoo.conf
	};
function run_odoo11{
	&"D:\odoo\odoo-11\venv-odoo11\Scripts\python.exe" D:\odoo\odoo-11\odoo-bin -c D:\odoo\odoo-11\odoo.conf
	};

