Write-Output "Checking for cd-extras module..."
if (!(Get-Module -ListAvailable -Name cd-extras)) { Install-Module cd-extras -Force }

Write-Output "Checking for PSReadLine module..."
if (!(Get-Module -ListAvailable -Name PSReadLine)) { Install-Module PSReadLine -Force }

Write-Output "Checking for Az module..."
if (!(Get-Module -ListAvailable -Name PSReadLine)) { Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force }

Write-Output "Checking for Terminal-Icons build dependencies..."
if (!(Get-Module -ListAvailable -Name BuildHelpers)) { Install-Module BuildHelpers -Force }
if (!(Get-Module -ListAvailable -Name PowerHtml)) { Install-Module PowerHtml -Force }
if (!(Get-Module -ListAvailable -Name PowerShellBuild)) { Install-Module PowerShellBuild -Force }
if (!(Get-Module -ListAvailable -Name psake)) { Install-Module psake -Force }
if (!(Get-Module -ListAvailable -Name PSScriptAnalyzer)) { Install-Module PSScriptAnalyzer -Force }
if (!(Get-Module -ListAvailable -Name PowerShellHumanizer)) { Install-Module PowerShellHumanizer -Force }

Write-Output "Copying starship.toml..."
Copy-Item -Path starship.toml -Destination "$HOME/.config";

Remove-Item -Path $Profile -Force;
New-Item -Path $Profile -Force;

Write-Output "Cloning custom Terminal-Icons repository..."
git clone "https://github.com/victor-borges/Terminal-Icons.git";
if ($IsWindows) { Unblock-File "$PSScriptRoot\Terminal-Icons\Terminal-Icons\Terminal-Icons.format.ps1xml" }
Set-Location "$PSScriptRoot\Terminal-Icons\"
& ".\build.ps1"
Set-Location $PSScriptRoot

Write-Output "Installing Terminal-Icons module..."
$separator = if ($IsWindows) { ";" } else { ":" }
Copy-Item -Recurse -Path ".\Terminal-Icons\Output\Terminal-Icons\" -Destination $env:PSModulePath.Split($separator)[0] -Force

if ($IsWindows) { & "$PSScriptRoot\scripts\windows.ps1" }
elseif ($IsLinux) { & "$PSScriptRoot\scripts\linux.ps1" }

Write-Output "Copying rest of Powershell profile contents..."
Add-Content -Path $Profile -Value (Get-Content ./Microsoft.PowerShell_profile.ps1)

Write-Output "All done!"
