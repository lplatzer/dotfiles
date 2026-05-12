# Dotfiles tool bootstrap for Windows
$ErrorActionPreference = "Continue"

function Test-CommandExists {
    param($command)
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Install-Tool {
    param(
        [string]$WingetId,
        [string]$CommandName
    )
    if (-not (Test-CommandExists $CommandName)) {
        Write-Host "Installing $CommandName..."
        winget install --id $WingetId --silent `
            --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "$CommandName already installed, skipping."
    }
}

Install-Tool "Zellij.Zellij"           "zellij"
Install-Tool "eza-community.eza"       "eza"
Install-Tool "ajeetdsouza.zoxide"      "zoxide"
Install-Tool "atuinsh.atuin"           "atuin"
Install-Tool "Starship.Starship"       "starship"
Install-Tool "BurntSushi.ripgrep.MSVC" "rg"
Install-Tool "sharkdp.fd"              "fd"
Install-Tool "junegunn.fzf"            "fzf"
Install-Tool "Neovim.Neovim"           "nvim"
Install-Tool "JesseDuffield.lazygit"   "lazygit"
Install-Tool "Git.Git"                 "git"
Install-Tool "OpenJS.NodeJS.LTS"       "node"
Install-Tool "GoLang.Go"               "go"
Install-Tool "Rustlang.Rustup"         "rustup"
Install-Tool "Microsoft.DotNet.SDK.9"  "dotnet"
