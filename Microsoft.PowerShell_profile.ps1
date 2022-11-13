Function Get-ChildItemForce { Get-ChildItem -Force }
New-Alias -Force l Get-ChildItem
New-Alias -Force ll Get-ChildItemForce
New-Alias -Force quit exit

Import-Module PSReadLine
Import-Module PowerShellHumanizer
Import-Module Terminal-Icons
Import-Module cd-extras

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
   param($commandName, $wordToComplete, $cursorPosition)
      dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
         [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
}

# Invoke Starship.rs
Invoke-Expression (&starship init powershell)
