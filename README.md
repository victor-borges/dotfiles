# 🔧 dotfiles

![Windows Terminal](docs/windows-terminal.png "Windows Terminal")

## Prerequisites

Have [Powershell Core](https://github.com/PowerShell/PowerShell) installed.

## Installation

The installation script will pull in the latest version and copy the files to your home folder, install the required packages and set Powershell as the login shell (if on Linux).

```powershell
git clone https://github.com/victor-borges/dotfiles.git; cd dotfiles; Set-ExecutionPolicy Bypass -Scope Process -Force; ./install.ps1
```
