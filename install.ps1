if (!(Get-Module -ListAvailable -Name cd-extras))
{
    Write-Output "Installing cd-extras module..."
    Install-Module cd-extras -Force;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Write-Output "Installing PSReadLine module..."
    Install-Module PSReadLine -Force;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Write-Output "Installing Az module..."
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

Copy-Item -Path starship.toml -Destination "$HOME/.config"

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

Add-Content -Path $Profile -Value (Get-Content ./Microsoft.PowerShell_profile.ps1)
