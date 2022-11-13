Write-Output "Checking the default shell..."
if ($env:SHELL -ne "/usr/bin/pwsh") {
    Write-Output "Changing default shell to Powershell..."
    chsh -s /usr/bin/pwsh
}

Write-Output "Checking for AMD GPU..."
if ((glxinfo | grep -iE 'vendor:').Contains('AMD')) {
    Write-Output "Applying fix for random crash from power management in Fedora (reboot necessary)..."
    sudo grubby --remove-args="amdgpu.ppfeaturemask" --args="amdgpu.ppfeaturemask=0xfffd3fff" --update-kernel=ALL
}

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
