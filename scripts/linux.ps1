if ($env:SHELL -ne "/usr/bin/pwsh")
{
    Write-Output "Changing default shell to Powershell..."
    chsh -s /usr/bin/pwsh
}

$env:STARSHIP_DISTRO =
{
    $distro = $(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

    switch -Wildcard ($distro)
    {
        '*kali*'        { '︀ ' }
        '*arch*'        { '︀ ' }
        '*debian*'      { '︀ ' }
        '*raspbian*'    { '︀ ' }
        '*ubuntu*'      { '︀ ' }
        '*elementary*'  { '︀ ' }
        '*fedora*'      { '︀ ' }
        '*coreos*'      { '︀ ' }
        '*gentoo*'      { '︀ ' }
        '*mageia*'      { '︀ ' }
        '*centos*'      { '︀ ' }
        '*opensuse*'    { '︀ ' }
        '*tumbleweed*'  { '︀ ' }
        '*sabayon*'     { '︀ ' }
        '*slackware*'   { '︀ ' }
        '*linuxmint*'   { '︀ ' }
        '*alpine*'      { '︀ ' }
        '*aosc*'        { '︀ ' }
        '*nixos*'       { '︀ ' }
        '*devuan*'      { '︀ ' }
        '*manjaro*'     { '︀ ' }
        '*rhel*'        { '︀ ' }
        default         { '︀ ' }
    }
}

[Environment]::SetEnvironmentVariable('STARSHIP_DISTRO', $env:STARSHIP_DISTRO, 'User')
