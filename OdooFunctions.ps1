function odoo-scaffold {
    <#
	This is a simplify for odoo scaffold commands.
	Usage odoo-scaffold 16 module_name
	#>
    param(
        [Parameter()]
        [Int64]$odoo_version,
        [Parameter()]
        [string]$module_name)

    try {
        &"C:\odoo\odoo$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" C:\odoo\odoo$odoo_version\odoo-bin scaffold $module_name C:\odoo\odoo$odoo_version\custom-addons
        $folder = "C:\odoo\odoo$odoo_version\custom-addons\" + $module_name
        if (Test-Path -Path $folder) {
            Write-Host "Module $module_name created seccessfully in odoo v$odoo_version"
        }
    }
    catch {
        Write-Host "Something wentwrong"
    }
	
}

function odoo-uninstall {
    <#
	This function is to uninstall odoo module from command becouse there is no officail way in docummentation to do this.
	Usage: odoo-uninstall 16 db_name module_name
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
        &"C:\odoo\odoo$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" C:\odoo\odoo$odoo_version\odoo-bin shell -d $dbname --addons-path=C:\odoo\odoo$odoo_version\custom-addons
        Write-Host "An uninstallation command has copied to clipboard please past it to the python command shell bellow"
        Set-Clipboard "self.env['ir.module.module'].search([('name', '=', '$module_name')]).button_immediate_uninstall()"
    }
    catch {
        Write-Host "Something wentwrong"
    }
	
}
function odoo-fix {
    <#
	This function is to fix the port if it used by another service, if the port is not used by any service the the Windows NAT Driver (winnat) 
	which is reserve ports for Windows use (even if Windows 10 isn't actually using them) so that no other programs on your computer can use these ports.
	This appeae in windows update 2018.
	Usage: odoo-fix 8016
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
function odoo {
    <#
	This function is to run odoo directly from command prompt.
	Usage: odoo 16 
	#>
    try {
        if ($args.Length -eq 1) {
            &"C:\odoo\odoo$args\venv-odoo$args\Scripts\python.exe" C:\odoo\odoo$args\odoo-bin --c C:\odoo\odoo$args\odoo.conf
        }
        elseif ($args.Length -gt 1) {
            $odoo_version = $args[0]
            $kwargs = $args[1..($args.Length - 1)]
            &"C:\odoo\odoo$odoo_version\venv-odoo$odoo_version\Scripts\python.exe" C:\odoo\odoo$odoo_version\odoo-bin $kwargs
        }
        else {
            Write-Host "enter the odoo version number followed by any anrguments you wnat"
        }	
    }
    catch {
        Write-Host "Not Fount"
    }
};

function odoo-ip {
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

function setup-odoo {
    <#
	.SYNOPSIS
	Sets up a new Odoo instance with git clone, virtual environment, and dependencies.
	
	.DESCRIPTION
	Creates a new Odoo installation in C:\odoo\odoo{version} with:
	- Git clone of Odoo (--depth 1)
	- Python virtual environment
	- Pip upgrade and requirements installation
	- Optional enterprise repository
	- Custom addons folder
	
	.PARAMETER version
	Odoo version number (e.g., 18, 19, 20)
	
	.PARAMETER enterprise
	Switch to also clone the enterprise repository
	
	.EXAMPLE
	setup-odoo 20
	
	.EXAMPLE
	setup-odoo 20 -enterprise
	#>
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Int64]$version,
		
        [Parameter(Mandatory = $false)]
        [switch]$enterprise
    )
	
    $odooRoot = "C:\odoo"
    $odooDir = "C:\odoo\odoo$version"
    $venvDir = "C:\odoo\odoo$version\venv-odoo$version"
    $customAddonsDir = "C:\odoo\odoo$version\custom-addons"
    $enterpriseDir = "C:\odoo\odoo$version\enterprise"
	
    try {
        # Create root directory if it doesn't exist
        if (-not (Test-Path $odooRoot)) {
            Write-Host "Creating $odooRoot..." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $odooRoot | Out-Null
        }
		
        # Check if odoo directory already exists
        if (Test-Path $odooDir) {
            Write-Warning "Directory $odooDir already exists. Aborting."
            return
        }
		
        # Clone Odoo repository
        Write-Host "Cloning Odoo $version.0 from GitHub..." -ForegroundColor Cyan
        Set-Location $odooRoot
        git clone https://github.com/odoo/odoo.git --depth 1 --branch $version.0 "odoo$version"
		
        if (-not (Test-Path $odooDir)) {
            Write-Error "Failed to clone Odoo repository"
            return
        }
		
        # Clone enterprise if requested
        if ($enterprise) {
            Write-Host "Cloning Odoo Enterprise $version.0..." -ForegroundColor Cyan
            Set-Location $odooDir
            git clone https://github.com/odoo/enterprise.git --depth 1 --branch $version.0 enterprise
        }
		
        # Create custom-addons directory
        Write-Host "Creating custom-addons directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $customAddonsDir | Out-Null
		
        # Create virtual environment
        Write-Host "Creating Python virtual environment..." -ForegroundColor Cyan
        python -m venv $venvDir
		
        if (-not (Test-Path "$venvDir\Scripts\python.exe")) {
            Write-Error "Failed to create virtual environment"
            return
        }
		
        # Upgrade pip
        Write-Host "Upgrading pip..." -ForegroundColor Cyan
        & "$venvDir\Scripts\python.exe" -m pip install --upgrade pip
		
        # Install requirements
        $requirementsFile = "$odooDir\requirements.txt"
        if (Test-Path $requirementsFile) {
            Write-Host "Installing Odoo requirements..." -ForegroundColor Cyan
            & "$venvDir\Scripts\python.exe" -m pip install -r $requirementsFile
        }
        else {
            Write-Warning "requirements.txt not found at $requirementsFile"
        }
		
        Write-Host "`nOdoo $version setup completed successfully!" -ForegroundColor Green
        Write-Host "Location: $odooDir" -ForegroundColor Green
        Write-Host "Virtual environment: $venvDir" -ForegroundColor Green
        if ($enterprise) {
            Write-Host "Enterprise: $enterpriseDir" -ForegroundColor Green
        }
        Write-Host "Custom addons: $customAddonsDir" -ForegroundColor Green
		
    }
    catch {
        Write-Error "An error occurred during setup: $($_.Exception.Message)"
    }
}
