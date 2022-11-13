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

Write-Output "Building and installing Terminal-Icons module..."
if ($IsWindows) { Unblock-File "$PSScriptRoot\Terminal-Icons\Terminal-Icons\Terminal-Icons.format.ps1xml" }
Set-Location "$PSScriptRoot\Terminal-Icons\"
& ".\build.ps1" *> $null
Set-Location $PSScriptRoot
$separator = if ($IsWindows) { ";" } else { ":" }
Copy-Item -Recurse -Path ".\Terminal-Icons\Output\Terminal-Icons\" -Destination $env:PSModulePath.Split($separator)[0] -Force

Write-Output "Copying starship.toml..."
Copy-Item -Path "./.config/starship.toml" -Destination "$HOME/.config" -Force *> $null

Write-Output "Copying kitty terminal config..."
Copy-Item -Path "./.config/kitty/kitty.conf" -Destination "$HOME/.config/kitty/kitty.conf" -Force *> $null

Remove-Item -Path $PROFILE -Force *> $null
New-Item -Path $PROFILE -Force *> $null

if ($IsWindows) { & "$PSScriptRoot\scripts\windows.ps1" }
elseif ($IsLinux) { & "$PSScriptRoot\scripts\linux.ps1" }

Write-Output "Copying rest of Powershell profile contents..."
Add-Content -Path $PROFILE -Value (Get-Content ./Microsoft.PowerShell_profile.ps1)

Write-Output "All done!"
