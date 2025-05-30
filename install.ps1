# Unsure Calculator Installation Script for Windows
# This script automatically downloads and installs Unsure Calculator

param(
    [string]$InstallDir = "$env:LOCALAPPDATA\unsure\bin"
)

# GitHub repository information
$Repo = "filiph/unsure"
$BinaryName = "unsure-windows.exe"

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Get latest release version
function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
        return $response.tag_name
    }
    catch {
        Write-Error "Failed to get latest version: $_"
        exit 1
    }
}

# Download and install binary
function Install-Binary {
    param(
        [string]$Version
    )
    
    $downloadUrl = "https://github.com/$Repo/releases/download/$Version/$BinaryName"
    $tempFile = [System.IO.Path]::GetTempFileName() + ".exe"
    $installPath = Join-Path $InstallDir "unsure.exe"
    
    Write-Status "Downloading Unsure Calculator $Version for Windows..."
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
    }
    catch {
        Write-Error "Download failed: $_"
        exit 1
    }
    
    if (-not (Test-Path $tempFile)) {
        Write-Error "Download failed - file not found"
        exit 1
    }
    
    Write-Status "Installing to $installPath..."
    
    # Create install directory if it doesn't exist
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    
    # Move binary to install location
    Move-Item $tempFile $installPath -Force
    
    Write-Status "Unsure Calculator installed successfully!"
    Write-Status "You can now run: unsure `"4~6 * 2~3`""
    
    return $installPath
}

# Add to PATH if needed
function Add-ToPath {
    param([string]$InstallDir)
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    
    if ($currentPath -notlike "*$InstallDir*") {
        Write-Status "Adding $InstallDir to your PATH..."
        $newPath = if ($currentPath) { "$currentPath;$InstallDir" } else { $InstallDir }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Status "PATH updated. You may need to restart your terminal."
    }
}

# Check for existing installation
function Test-ExistingInstallation {
    try {
        $existing = Get-Command unsure -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Warning "Unsure Calculator is already installed at: $($existing.Source)"
            $response = Read-Host "Do you want to continue and update? [y/N]"
            if ($response -notmatch '^[Yy]$') {
                Write-Host "Installation cancelled."
                exit 0
            }
        }
    }
    catch {
        # No existing installation found, continue
    }
}

# Main installation function
function Main {
    Write-Host "=== Unsure Calculator Installation Script ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Check for existing installation
    Test-ExistingInstallation
    
    # Get latest version
    $version = Get-LatestVersion
    Write-Status "Latest version: $version"
    
    # Install binary
    $installPath = Install-Binary -Version $version
    
    # Add to PATH
    Add-ToPath -InstallDir $InstallDir
    
    Write-Host ""
    Write-Status "Installation complete!"
    Write-Status "Try running: unsure `"10~20 * 2`""
    Write-Host ""
    Write-Host "If the command is not found, restart your terminal or run:" -ForegroundColor Yellow
    Write-Host "`$env:PATH += `";$InstallDir`"" -ForegroundColor Yellow
}

# Run main function
Main 