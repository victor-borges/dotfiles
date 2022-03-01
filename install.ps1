if (!(Get-Module -ListAvailable -Name cd-extras))
{
    Install-Module cd-extras;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Install-Module PSReadLine -Force;
}

Copy-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $Profile
Copy-Item -Path starship.toml -Destination "$HOME/.config"
