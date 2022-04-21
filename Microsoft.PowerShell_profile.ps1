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

   $LastFetchFilePath = "$(git rev-parse --show-toplevel)/.git/STARSHIP_LAST_FETCH"
   $LastFetch = [DateTime]::ParseExact((Get-Content -Path $LastFetchFilePath), "o", [CultureInfo]::InvariantCulture)
   $IsInsideGitRepository = $(git rev-parse --is-inside-work-tree) -eq 'true'

   if ((Get-Date) - $LastFetch -gt [TimeSpan]::FromSeconds(30) -and $IsInsideGitRepository) {
      Start-Job -ScriptBlock { git fetch } *> $null
      Set-Content -Path $LastFetchFilePath -Value (Get-Date).ToString("o", [CultureInfo]::InvariantCulture)
   }
}

# Invoke Starship.rs
Invoke-Expression (&starship init powershell)
