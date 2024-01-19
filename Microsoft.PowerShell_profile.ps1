Import-Module PSReadLine
Import-Module PowerShellHumanizer
Import-Module Terminal-Icons
Import-Module cd-extras

Function Get-ChildItemForce { Get-ChildItem -Force }
New-Alias -Force l Get-ChildItem
New-Alias -Force ll Get-ChildItemForce
New-Alias -Force quit exit

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete

Invoke-Expression (&starship init powershell)
