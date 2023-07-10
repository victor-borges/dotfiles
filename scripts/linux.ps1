# Write-Output "Checking the default shell..."
# if (!$env:SHELL.StartsWith("/usr/bin/pwsh")) {
#     Write-Output "Changing default shell to Powershell..."

#     $testChsh = chsh;
#     $testLchsh = lchsh;

#     if ($testChsh) {
#         chsh -s /usr/bin/pwsh
#     } elseif ($testLchsh) {
#         Write-Output /usr/bin/pwsh | sudo lchsh $env:USER
#     }
# }

# Write-Output "Checking for AMD GPU..."
# if ((glxinfo | grep -iE 'vendor:').Contains('AMD') -and !((sudo grubby --info=DEFAULT | grep -iE 'args=').Contains('amdgpu.ppfeaturemask=0xfffd3fff'))) {
#     Write-Output "Applying fix for random crash from power management in Fedora (reboot necessary)..."
#     sudo grubby --remove-args="amdgpu.ppfeaturemask" --args="amdgpu.ppfeaturemask=0xfffd3fff" --update-kernel=ALL
# }

# Write-Output "Installing Papirus icon theme..."
# wget -qO- https://git.io/papirus-icon-theme-install | sh

# Write-Output "Preparing Source folder (should already be there)..."
# New-Item -Path "$HOME/Source" -Force *> $null
# Set-Location "$HOME/Source"

# Write-Output "Installing anino-dock..."
# git clone https://github.com/icedman/anino-dock.git *> $null
# Set-Location "$HOME/Source/anino-dock"
# make *> $null

# Write-Output "Installing Hardcoded Icon Fixer..."
# git clone https://github.com/Foggalong/hardcode-fixer.git *> $null
# Set-Location "$HOME/Source/hardcode-fixer"
# sudo ./fix.sh *> $null

# Set-Location $PSScriptRoot

# Write-Output "Installing Hardcode-Tray..."
# sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:SmartFinn:hardcode-tray/Fedora_$(rpm -E %fedora)/home:SmartFinn:hardcode-tray.repo *> $null
# sudo dnf install -y hardcode-tray *> $null
# sudo -E hardcode-tray --conversion-tool RSVGConvert --size 22 --theme Papirus --apply *> $null

# Write-Output "Restoring Gnome settings..."
# sh -c "dconf dump / < ./gnome_backup.conf"

# Write-Output "Copying kitty terminal config..."
# Copy-Item -Path "./.config/kitty/kitty.conf" -Destination "$HOME/.config/kitty/kitty.conf" -Force *> $null

Write-Output "Adding distro icon to prompt..."
$env:STARSHIP_DISTRO = switch -Wildcard ($(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')) {
    '*kali*'        { '︀  ' }
    '*arch*'        { '︀  ' }
    '*debian*'      { '︀  ' }
    '*raspbian*'    { '︀  ' }
    '*ubuntu*'      { '︀  ' }
    '*elementary*'  { '︀  ' }
    '*fedora*'      { '  ' }
    '*nobara*'      { '  ' }
    '*coreos*'      { '︀  ' }
    '*gentoo*'      { '︀  ' }
    '*mageia*'      { '︀  ' }
    '*centos*'      { '︀  ' }
    '*opensuse*'    { '︀  ' }
    '*tumbleweed*'  { '︀  ' }
    '*sabayon*'     { '︀  ' }
    '*slackware*'   { '︀  ' }
    '*linuxmint*'   { '︀  ' }
    '*alpine*'      { '︀  ' }
    '*aosc*'        { '︀  ' }
    '*nixos*'       { '︀  ' }
    '*devuan*'      { '︀  ' }
    '*manjaro*'     { '︀  ' }
    '*rhel*'        { '︀  ' }
    default         { '︀  ' }
}

Add-Content $PROFILE -Value "`$env:STARSHIP_DISTRO = '$env:STARSHIP_DISTRO'"
