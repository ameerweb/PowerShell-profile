v1.3.0
 - Refactor Odoo functions into separate OdooFunctions.ps1 file for better organization
 - Auto-load Odoo functions on profile startup
 - Update directory naming convention from odoo-{version} to odoo{version}
 - Change Odoo installation path from D:\ to C:\
 - Add setup-odoo function to automate Odoo installation (git clone, venv, pip install)
 - Support enterprise edition installation with -enterprise flag

v1.2.0
 - Update README.md with setup instructions (Oh-My-Posh, Fonts, Terminal-Icons, PSReadLine).
 - Fix Oh-My-Posh initialization error (stale cache).
 - Add .gitignore to exclude Modules and temporary files.

v1.1.0
 - ip_odoo() now allow port in firewall settings
 - delete ip() and ipw() deleted.
v1.0.0
 - This is the first version of powershell profile.
 - Add aliases 
 - add utilities
 - Add odoo functions to help in odoo development
 - basic scipting automation.

