#!/bin/bash

# Unsure Calculator Installation Script
# This script automatically downloads and installs the appropriate binary for your platform

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub repository information
REPO="filiph/unsure"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    local os
    local arch
    
    case "$(uname -s)" in
        Linux*)     os="linux";;
        Darwin*)    os="macos";;
        CYGWIN*|MINGW*|MSYS*) os="windows";;
        *)          print_error "Unsupported operating system: $(uname -s)"; exit 1;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64) arch="x64";;
        arm64|aarch64) arch="arm64";;
        *) print_error "Unsupported architecture: $(uname -m)"; exit 1;;
    esac
    
    echo "${os}"
}

# Get latest release version
get_latest_version() {
    local version
    version=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$version" ]; then
        print_error "Failed to get latest version"
        exit 1
    fi
    
    echo "$version"
}

# Download and install binary
install_binary() {
    local platform="$1"
    local version="$2"
    local binary_name="unsure-${platform}"
    local extension=""
    
    if [ "$platform" = "windows" ]; then
        extension=".exe"
        binary_name="${binary_name}${extension}"
    fi
    
    local download_url="https://github.com/${REPO}/releases/download/${version}/${binary_name}"
    local temp_file="/tmp/unsure${extension}"
    local install_path="${INSTALL_DIR}/unsure${extension}"
    
    print_status "Downloading Unsure Calculator ${version} for ${platform}..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -sL "$download_url" -o "$temp_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$download_url" -O "$temp_file"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    if [ ! -f "$temp_file" ]; then
        print_error "Download failed"
        exit 1
    fi
    
    print_status "Installing to ${install_path}..."
    
    # Create install directory if it doesn't exist
    mkdir -p "$(dirname "$install_path")"
    
    # Move binary to install location
    if [ -w "$(dirname "$install_path")" ]; then
        mv "$temp_file" "$install_path"
        chmod +x "$install_path"
    else
        print_status "Installation requires sudo privileges..."
        sudo mv "$temp_file" "$install_path"
        sudo chmod +x "$install_path"
    fi
    
    print_status "Unsure Calculator installed successfully!"
    print_status "You can now run: unsure \"4~6 * 2~3\""
}

# Check if binary is already in PATH
check_existing_installation() {
    if command -v unsure >/dev/null 2>&1; then
        local existing_version
        existing_version=$(unsure --help 2>&1 | head -1 | grep -o 'v[0-9]*\.[0-9]*\.[0-9]*' || echo "unknown")
        print_warning "Unsure Calculator is already installed (${existing_version})"
        read -p "Do you want to continue and update? [y/N] " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
}

# Main installation function
main() {
    echo "=== Unsure Calculator Installation Script ==="
    echo
    
    # Check for existing installation
    check_existing_installation
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    print_status "Detected platform: $platform"
    
    # Get latest version
    local version
    version=$(get_latest_version)
    print_status "Latest version: $version"
    
    # Install binary
    install_binary "$platform" "$version"
    
    echo
    print_status "Installation complete!"
    print_status "Try running: unsure \"10~20 * 2\""
    
    # Add to PATH instructions if needed
    if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
        echo
        print_warning "Note: ${INSTALL_DIR} is not in your PATH."
        print_warning "Add this line to your shell profile (.bashrc, .zshrc, etc.):"
        echo "export PATH=\"\$PATH:${INSTALL_DIR}\""
    fi
}

# Run main function
main "$@" 