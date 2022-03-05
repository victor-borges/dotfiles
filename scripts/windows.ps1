[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;

$testScoop = pwsh scoop -v
if (!($testScoop))
{
    Write-Output "Installing Scoop..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'));
}

$testSudo = pwsh sudo
if (!($testSudo))
{
    Write-Output "Installing Sudo for Windows..."
    pwsh scoop install sudo
}

$testStarship = pwsh starship --version
if (!($testStarship))
{
    Write-Output "Installing Starship prompt..."
    pwsh scoop install starship
}

$testChoco = pwsh choco -v
if (!($testChoco))
{
    Write-Output "Installing Chocolatey..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
}

$terminalSettingsFilePath = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";
Copy-Item -Path .\settings.json -Destination $terminalSettingsFilePath -Force

$env:STARSHIP_DISTRO = '者︀ ';
[Environment]::SetEnvironmentVariable('STARSHIP_DISTRO', $env:STARSHIP_DISTRO, 'User')
