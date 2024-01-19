Write-Output "Checking the default shell..."
if (!$env:SHELL.StartsWith("/usr/bin/pwsh")) {
    Write-Output "Changing default shell to Powershell..."

    $testChsh = chsh;
    $testLchsh = lchsh;

    if ($testChsh) {
        chsh -s /usr/bin/pwsh
    } elseif ($testLchsh) {
        Write-Output /usr/bin/pwsh | sudo lchsh $env:USER
    }
}

# Write-Output "Installing Hardcoded Icon Fixer..."
# git clone https://github.com/Foggalong/hardcode-fixer.git *> $null
# Set-Location "$HOME/Source/hardcode-fixer"
# sudo ./fix.sh *> $null

# Write-Output "Installing Hardcode-Tray..."
# sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:SmartFinn:hardcode-tray/Fedora_$(rpm -E %fedora)/home:SmartFinn:hardcode-tray.repo *> $null
# sudo dnf install -y hardcode-tray *> $null
# sudo -E hardcode-tray --conversion-tool RSVGConvert --size 22 --theme Papirus --apply *> $null
