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

function Test-Any {
   param($EvaluateCondition,
       [Parameter(ValueFromPipeline = $true)] $ObjectToTest)
   begin {
       $any = $false
   }
   process {
       if (-not $any -and (& $EvaluateCondition $ObjectToTest)) {
           $any = $true
       }
   }
   end {
       $any
   }
}

if ($IsWindows)
{
   $terminalSettingsFilePath = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";
   if (Test-Path $terminalSettingsFilePath)
   {
      $settings = Get-Content $terminalSettingsFilePath -Raw | ConvertFrom-Json -Depth 100;
      $action = '{ "keys": "ctrl+backspace", "command": { "action": "sendInput", "input": "\u0017" } }' | ConvertFrom-Json;

      if (-not ($settings.actions | Test-Any { $_.keys -eq $action.keys }))
      {
         $settings.actions += $action;
         $settings | ConvertTo-Json -Depth 100 | Set-Content $terminalSettingsFilePath;
      }
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
