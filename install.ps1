if (!(Get-Module -ListAvailable -Name cd-extras))
{
    Install-Module cd-extras;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Install-Module PSReadLine -Force;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

if (!(choco --version))
{
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
}

Copy-Item -Path starship.toml -Destination "$HOME/.config"

if ($IsWindows)
{
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

if ($IsLinux)
{
    Write-Warning "The following command will ask for your password to change the shell." -WarningAction Inquire
    chsh -s /usr/bin/pwsh
}

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

"`$ENV:STARSHIP_DISTRO = '$icon '$([System.Environment]::NewLine)" | Out-File -FilePath $Profile
Add-Content -Path $Profile -Value (Get-Content ./Microsoft.PowerShell_profile.ps1)
