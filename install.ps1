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

function Update-Choco-Packages {
    # Resolve the path to the chocolatey executable.
    $chocoPath = Get-Command choco.exe -ErrorAction SilentlyContinue

    $process = Start-Process `
        -FilePath $chocoPath.Path `
        -ArgumentList "upgrade all -y" `
        -Verb RunAs -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Host "Chocolatey failed to update packages."
    }
}

# Installs a package using chocolatey. Accepts a package name and an executable
# to check if it's already installed.
function Install-With-Choco-If-Not-Exists {
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
                -FilePath "choco" `
                -ArgumentList "install -y $package" `
                -Verb RunAs `
                -Wait
        } else {
            Write-Host "Skipping '$package'..."
        }
    }
}

# Installs a package using winget. Accepts a package name and an executable
# to check if it's already installed.
function Install-With-Winget-If-Not-Exists {
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
                -FilePath "winget" `
                -ArgumentList "install $package" `
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
    Write-Host "Choco is already installed, updating..."
    # Update choco packages
    Update-Choco-Packages
} else {
    if (Get-User-Consent "Install Chocolatey?") {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol =
            [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        # Execute as admin
        Start-Process `
            -FilePath "powershell" `
            -ArgumentList "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" `
            -Verb RunAs `
            -Wait
    } else {
        Write-Host "Chocolatey is needed to run this script. Exiting..."
        return $false
    }
}

# Update all winget packages
# Print that we're going to update all winget packages
Write-Host "Updating all winget packages..."
Start-Process `
    -FilePath "winget" `
    -ArgumentList "upgrade --all --accept-source-agreements --accept-package-agreements --accept-licenses" `
    -Verb RunAs `
    -Wait

# Configure PowerShell
Copy-Item `
    -Path "./src/profile.ps1" `
    -Destination `
        "C:\Users\$env:UserName\Documents\WindowsPowerShell\profile.ps1"

# Install choco packages:
Install-With-Winget-If-Not-Exists "Git.Git" "git"
Install-With-Choco-If-Not-Exists "curl"

# Vim's a big one:
Install-With-Winget-If-Not-Exists "vim.vim" "vim"
Copy-Item -Path "./src/vimrc" -Destination "C:\Users\$env:UserName\_vimrc"
Install-With-Choco-If-Not-Exists "fzf"

## Install Vim-Plug
Invoke-WebRequest `
    -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim `
    | New-Item $HOME/vimfiles/autoload/plug.vim -Force

Invoke-Expression "vim +PlugInstall +PlugClean +qall"

# Install other packages
Install-With-Winget-If-Not-Exists "Microsoft.Powershell" "pwsh"
Install-With-Winget-If-Not-Exists "Microsoft.VisualStudioCode" "code"
Install-With-Winget-If-Not-Exists "GnuWin32.Make" "make"
Install-With-Winget-If-Not-Exists "Python.Python.3.11" "python"
Install-With-Winget-If-Not-Exists "OpenJS.NodeJS.LTS" "node"
Install-With-Winget-If-Not-Exists "Insecure.Nmap" "nmap"
Install-With-Winget-If-Not-Exists "GnuWin32.Grep" "grep"
