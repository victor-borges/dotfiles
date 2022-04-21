Set-Alias l ls

Import-Module PSReadLine
Import-Module PowerShellHumanizer
Import-Module Terminal-Icons
Import-Module cd-extras

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
   param($commandName, $wordToComplete, $cursorPosition)
      dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
         [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
}

# Executes git fetch if inside a git repository
function Invoke-Starship-PreCommand {
   if ($(git rev-parse --is-inside-work-tree) -eq 'true') {
      Start-Job -ScriptBlock { git fetch }
   }
}

# Invoke Starship.rs
Invoke-Expression (&starship init powershell)
