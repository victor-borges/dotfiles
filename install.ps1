Write-Output "Checking for cd-extras module..."
if (!(Get-Module -ListAvailable -Name cd-extras))
{
    Write-Output "cd-extras module not found"
    Install-Module cd-extras -Force;
}

Write-Output "Checking for PSReadLine module..."
if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Write-Output "PSReadLine module not found"
    Install-Module PSReadLine -Force;
}

Write-Output "Checking for Az module..."
if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Write-Output "Az module not found"
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

Write-Progress -CurrentOperation "CopyStarshipSettings" ("Copying starship.toml...")
Copy-Item -Path starship.toml -Destination "$HOME/.config"
Write-Progress -CurrentOperation "CopyStarshipSettings" ("Copying starship.toml... Done!") -Completed

if (!(Test-Path $Profile))
{
    New-Item -Path $Profile
}

if ($IsWindows)
{
    & "$PSScriptRoot\scripts\windows.ps1"
}
elseif ($IsLinux)
{
    & "$PSScriptRoot\scripts\linux.ps1"
}

Write-Progress -CurrentOperation "CopyPowershellProfile" ("Copying Powershell profile...")
Add-Content -Path $Profile -Value (Get-Content ./Microsoft.PowerShell_profile.ps1)
Write-Progress -CurrentOperation "CopyPowershellProfile" ("Copying Powershell profile... Done!")

Write-Output "All done!"
