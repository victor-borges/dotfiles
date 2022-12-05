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

Write-Output "Checking for AMD GPU..."
if ((glxinfo | grep -iE 'vendor:').Contains('AMD') -and !((sudo grubby --info=DEFAULT | grep -iE 'args=').Contains('amdgpu.ppfeaturemask=0xfffd3fff'))) {
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
