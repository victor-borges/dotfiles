Write-Output "Checking the default shell..."
if ($env:SHELL -ne "/usr/bin/pwsh")
{
    Write-Output "Changing default shell to Powershell..."
    chsh -s /usr/bin/pwsh
}

# Stopped working, don't know why
Add-Content $profile -Value '$env:STARSHIP_DISTRO = "︀ ";'
[Environment]::SetEnvironmentVariable('STARSHIP_DISTRO', $env:STARSHIP_DISTRO, 'User')
