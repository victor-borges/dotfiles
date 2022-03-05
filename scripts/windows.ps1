[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;

Write-Output "Checking for Scoop installation..."
$testScoop = pwsh scoop -v
if (!($testScoop))
{
    Write-Output "Scoop not found"
    Write-Progress -CurrentOperation "InstallScoop" ("Installing Scoop...")
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'));
    Write-Progress -CurrentOperation "InstallScoop" ("Installing Scoop... Done!") -Completed
}

Write-Output  "Checking for Sudo for Windows installation..."
$testSudo = pwsh sudo
if (!($testSudo))
{
    Write-Output "Sudo for Windows not found"
    Write-Progress -CurrentOperation "InstallSudo" ("Installing Sudo for Windows...")
    pwsh scoop install sudo
    Write-Progress -CurrentOperation "InstallSudo" ("Installing Sudo for Windows... Done!") -Completed
}

Write-Output "Checking for Starship prompt installation..."
$testStarship = pwsh starship --version
if (!($testStarship))
{
    Write-Output "Starship not found"
    Write-Progress -CurrentOperation "InstallStarship" ("Installing Starship...")
    pwsh scoop install starship
    Write-Progress -CurrentOperation "InstallStarship" ("Installing Starship... Done!") -Completed
}

Write-Output "Checking for Chocolatey installation..."
$testChoco = pwsh choco -v
if (!($testChoco))
{
    Write-Output "Chocolatey not found"
    Write-Progress -CurrentOperation "InstallChocolatey" ("Installing Chocolatey...")
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
    Write-Progress -CurrentOperation "InstallChocolatey" ("Installing Chocolatey... Done!") -Completed
}

Write-Progress -CurrentOperation "CopyWindowsTerminalSettings" ("Copying Windows Terminal settings...")
$terminalSettingsFilePath = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";
Copy-Item -Path .\settings.json -Destination $terminalSettingsFilePath -Force
Write-Progress -CurrentOperation "CopyWindowsTerminalSettings" ("Copying Windows Terminal settings... Done!") -Completed

$env:STARSHIP_DISTRO = '者︀ ';
[Environment]::SetEnvironmentVariable('STARSHIP_DISTRO', $env:STARSHIP_DISTRO, 'User')
