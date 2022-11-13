[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Write-Output "Checking for Scoop installation..."
$testScoop = pwsh scoop -v
if (!($testScoop)) {
    Write-Output "Installing Scoop..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))
}

Write-Output  "Checking for Sudo for Windows installation..."
$testSudo = pwsh sudo
if (!($testSudo)) {
    Write-Output "Installing Sudo for Windows..."
    pwsh scoop install sudo
}

Write-Output "Checking for Starship prompt installation..."
$testStarship = pwsh starship --version
if (!($testStarship)) {
    Write-Output "Installing Starship..."
    pwsh scoop install starship
}

Write-Output "Checking for Chocolatey installation..."
$testChoco = pwsh choco -v
if (!($testChoco)) {
    Write-Output "Installing Chocolatey..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

$env:STARSHIP_DISTRO = '者 '
[Environment]::SetEnvironmentVariable('STARSHIP_DISTRO', $env:STARSHIP_DISTRO, 'User')
