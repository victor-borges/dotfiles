Install-Module cd-extras;
Install-Module PSReadLine -Force;

Copy-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $Profile
Copy-Item -Path starship.toml -Destination "$HOME/.config"
