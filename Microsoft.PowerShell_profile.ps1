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

# # Executes git fetch if inside a git repository
# function Invoke-Starship-PreCommand {
#    $LastFetchFilePath = "$(git rev-parse --show-toplevel)/.git/STARSHIP_LAST_FETCH"
   
#    if ((Test-Path $LastFetchFilePath) -or -not (Get-Content -Path $LastFetchFilePath))
#    {
#       $LastFetch = [DateTime]::ParseExact((Get-Content -Path $LastFetchFilePath), "o", [CultureInfo]::InvariantCulture)
#       $IsInsideGitRepository = $(git rev-parse --is-inside-work-tree) -eq 'true'

#       if ((Get-Date) - $LastFetch -gt [TimeSpan]::FromSeconds(30) -and $IsInsideGitRepository) {
#          Update-GitRepositoryInfo -LastFetchFilePath $LastFetchFilePath
#       }
#    }
#    else
#    {
#       New-Item $LastFetchFilePath -Force
#       Update-GitRepositoryInfo -LastFetchFilePath $LastFetchFilePath
#    }
# }

# function Update-GitRepositoryInfo {
#    param(
#       [string]$LastFetchFilePath
#    )

#    Start-Job -ScriptBlock { git fetch }
#    Set-Content -Path $LastFetchFilePath -Value (Get-Date).ToString("o", [CultureInfo]::InvariantCulture)
# }

# Invoke Starship.rs
Invoke-Expression (&starship init powershell)
