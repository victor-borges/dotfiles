Set-Alias l ls

Import-Module PSReadLine
Import-Module cd-extras

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
   param($commandName, $wordToComplete, $cursorPosition)
      dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
         [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
}

# Find out which OS we are running on
$icon =
   if ($IsWindows) { '者︀' }
   elseif ($IsMacOS) { '︀' }
   elseif ($IsLinux)
   {
      $distro = $(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

      switch -Wildcard ($distro)
      {
         '*kali*'        { '︀' }
         '*arch*'        { '︀' }
         '*debian*'      { '︀' }
         '*raspbian*'    { '︀' }
         '*ubuntu*'      { '︀' }
         '*elementary*'  { '︀' }
         '*fedora*'      { '︀' }
         '*coreos*'      { '︀' }
         '*gentoo*'      { '︀' }
         '*mageia*'      { '︀' }
         '*centos*'      { '︀' }
         '*opensuse*'    { '︀' }
         '*tumbleweed*'  { '︀' }
         '*sabayon*'     { '︀' }
         '*slackware*'   { '︀' }
         '*linuxmint*'   { '︀' }
         '*alpine*'      { '︀' }
         '*aosc*'        { '︀' }
         '*nixos*'       { '︀' }
         '*devuan*'      { '︀' }
         '*manjaro*'     { '︀' }
         '*rhel*'        { '︀' }
         default         { '︀' }
      }
   }

# Invoke Starship.rs
$ENV:STARSHIP_DISTRO = "$icon "
Invoke-Expression (&starship init powershell)
