#
# Helper functions
#

function User-Wants-To {
    param (
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

function Command-Exists {
    param ($command)

    $oldPreference = $ErrorActionPreference

    $ErrorActionPreference = "stop"

    try {
        if (Get-Command $command) {
            return $true
        }
    } catch {
        Write-Host "$command does not exist"
        return $false
    } finally {
        $ErrorActionPreference=$oldPreference
    }
}

function Install-If-Not-Exists {
    param ($package)

    if (Command-Exists $package) {
        Write-Host "'$package' is already installed, skipping..."
    } else {
        if (User-Wants-To "Install '$package'?") {
            Write-Host "Installing '$package'..."
            Start-Process `
                -File "choco" `
                -ArgumentList "install -y '$package'" `
                -Verb RunAs `
                -Wait
        } else {
            Write-Host "Skipping '$package'..."
        }
    }
}

if (Command-Exists "choco") {
    Write-Host "Choco is already installed, skipping..."
} else {
    if (User-Wants-To "Install Chocolatey?") {
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

# Install choco packages:
Install-If-Not-Exists "git"
Install-If-Not-Exists "code"
Install-If-Not-Exists "vim"
