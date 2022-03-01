if (!(Get-Module -ListAvailable -Name cd-extras))
{
    Install-Module cd-extras;
}

if (!(Get-Module -ListAvailable -Name PSReadLine))
{
    Install-Module PSReadLine -Force;
}

Copy-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $Profile
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
