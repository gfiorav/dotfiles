#
# Helper functions
#

function Get-User-Consent {
    Param (
        $prompt
    )

    $response = Read-Host -Prompt "'$prompt' [y/N]"

    # TODO: match uppercase Y too.
    if ($response -eq "y") {
        return $true
    } else {
        return $false
    }
}

# Sniped from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
function Test-Command-Exists {
    Param ($command)

    $oldPreference = $ErrorActionPreference

    $ErrorActionPreference = "stop"

    try {
        if (Get-Command $command) {
            return $true
        }
    } catch {
        Write-Host "'$command' is not installed."
        return $false
    } finally {
        $ErrorActionPreference=$oldPreference
    }
}

function Install-If-Not-Exists {
    Param (
        $package,
        $bin_name
    )

    if ($null -eq $bin_name) {
        $bin = $package
    } else {
        $bin = $bin_name
    }

    if (Test-Command-Exists $bin) {
        Write-Host "'$package' is already installed, skipping..."
    } else {
        if (Get-User-Consent "Install '$package'?") {
            Write-Host "Installing '$package'..."
            Start-Process `
                -File "choco" `
                -ArgumentList "install -y $package" `
                -Verb RunAs `
                -Wait
        } else {
            Write-Host "Skipping '$package'..."
        }
    }
}

function Install-Vim-Plugins {
    Param ($plugin_names)

    $github_url = "https://github.com"
    foreach ($plugin_name in $plugin_names) {
        Invoke-Expression `
            "git clone $github_url/$plugin_name C:\Users\$env:UserName\vimfiles\plugin\$plugin_name"
    }
}

if (Test-Command-Exists "choco") {
    Write-Host "Choco is already installed, skipping..."
} else {
    if (Get-User-Consent "Install Chocolatey?") {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol =
            [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression (
            (New-Object System.Net.WebClient).DownloadString(
                "https://community.chocolatey.org/install.ps1"
            )
        )
    } else {
        Write-Host "Chocolatey is needed to run this script. Exiting..."
        return $false
    }
}

# Configure PowerShell
Copy-Item `
    -Path "./src/profile.ps1" `
    -Destination `
        "C:\Users\$env:UserName\Documents\WindowsPowerShell\profile.ps1"

# Install choco packages:
Install-If-Not-Exists "git"
Install-If-Not-Exists "curl"

# Vim's a big one:
Install-If-Not-Exists "vim"
Copy-Item -Path "./src/vimrc" -Destination "C:\Users\$env:UserName\_vimrc"
Install-If-Not-Exists "fzf"

## Install Vim-Plug
Invoke-WebRequest `
    -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim `
    | New-Item $HOME/vimfiles/autoload/plug.vim -Force

Invoke-Expression "vim +PlugInstall +PlugClean +qall"

# Install other packages
Install-If-Not-Exists "code"
Install-If-Not-Exists "make"
Install-If-Not-Exists "python"
Install-If-Not-Exists "nodejs-lts" "node"
Install-If-Not-Exists "sudo"
Install-If-Not-Exists "nmap"
Install-If-Not-Exists "grep"
Install-If-Not-Exists "less"
Install-If-Not-Exists "sqlite" "sqlite3"
Install-If-Not-Exists "ctags"
