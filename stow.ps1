#!/usr/bin/env pwsh
# PowerShell Stow Script - Windows equivalent of GNU Stow
# Creates symlinks from dotfiles to their target locations

param(
    [Parameter(Mandatory=$false)]
    [string[]]$Packages,

    [Parameter(Mandatory=$false)]
    [switch]$All,

    [Parameter(Mandatory=$false)]
    [switch]$Restow,

    [Parameter(Mandatory=$false)]
    [switch]$Delete,

    [Parameter(Mandatory=$false)]
    [string]$DotfilesDir = $PSScriptRoot
)

# Colors for output
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "! $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "→ $msg" -ForegroundColor Cyan }

# Check if running as Administrator
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Warning "Not running as Administrator. Some symlinks may fail to create."
    Write-Warning "Consider running: Start-Process pwsh -Verb RunAs -ArgumentList '-File $PSCommandPath'"
}

# Map package-specific target directories
function Get-TargetPath {
    param(
        [string]$Package,
        [string]$RelativePath
    )

    # Special handling for specific packages
    switch ($Package) {
        "nvim" {
            # Map .config/nvim to $env:LOCALAPPDATA\nvim (Windows convention)
            if ($RelativePath -match '^\.config[\\/]nvim(.*)$') {
                return Join-Path $env:LOCALAPPDATA "nvim$($Matches[1])"
            }
        }
        "ohmyposh" {
            # Oh-my-posh configs go to a known location
            return Join-Path $HOME ".config" $RelativePath
        }
    }

    # Default: map to $HOME
    return Join-Path $HOME $RelativePath
}

# Create a symlink
function New-Symlink {
    param(
        [string]$Target,
        [string]$Link,
        [bool]$IsDirectory
    )

    # Check if link already exists
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq "SymbolicLink") {
            if ($Restow -or $Delete) {
                Write-Info "Removing existing symlink: $Link"
                Remove-Item $Link -Force -Recurse
            } else {
                Write-Warning "Symlink already exists: $Link"
                return $false
            }
        } else {
            Write-Warning "File/Directory already exists (not a symlink): $Link"
            return $false
        }
    }

    if ($Delete) {
        return $true
    }

    # Ensure parent directory exists
    $parentDir = Split-Path $Link -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Create symlink
    try {
        $itemType = if ($IsDirectory) { "Directory" } else { "File" }
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Success "Linked: $Link -> $Target"
        return $true
    } catch {
        Write-Error "Failed to create symlink: $Link -> $Target"
        Write-Error $_.Exception.Message
        return $false
    }
}

# Process a package
function Invoke-Stow {
    param(
        [string]$Package
    )

    $packagePath = Join-Path $DotfilesDir $Package

    if (-not (Test-Path $packagePath)) {
        Write-Error "Package not found: $Package"
        return
    }

    Write-Info "Processing package: $Package"

    # Get all files and directories in the package
    $items = Get-ChildItem -Path $packagePath -Recurse -Force

    foreach ($item in $items) {
        # Get relative path from package root
        $relativePath = $item.FullName.Substring($packagePath.Length + 1)

        # Get target path
        $targetPath = Get-TargetPath -Package $Package -RelativePath $relativePath

        if ($item.PSIsContainer) {
            # For directories, just ensure they exist (symlink individual files instead)
            continue
        } else {
            # For files, create symlink
            New-Symlink -Target $item.FullName -Link $targetPath -IsDirectory $false
        }
    }
}

# Main execution
try {
    if ($All) {
        # Get all subdirectories as packages
        $Packages = Get-ChildItem -Path $DotfilesDir -Directory |
                    Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'assets' -and $_.Name -ne 'scripts' } |
                    Select-Object -ExpandProperty Name
    }

    if (-not $Packages) {
        Write-Host "Usage: .\stow.ps1 [-Packages] <package1>,<package2> [-All] [-Restow] [-Delete]"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  .\stow.ps1 nvim,wezterm          # Stow nvim and wezterm"
        Write-Host "  .\stow.ps1 -All                  # Stow all packages"
        Write-Host "  .\stow.ps1 nvim -Restow          # Re-stow nvim (remove and recreate)"
        Write-Host "  .\stow.ps1 nvim -Delete          # Remove nvim symlinks"
        Write-Host ""
        Write-Host "Available packages:"
        Get-ChildItem -Path $DotfilesDir -Directory |
            Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'assets' -and $_.Name -ne 'scripts' } |
            ForEach-Object { Write-Host "  - $($_.Name)" }
        exit 0
    }

    foreach ($pkg in $Packages) {
        Invoke-Stow -Package $pkg
    }

    Write-Success "Done!"

} catch {
    Write-Error "An error occurred: $_"
    exit 1
}
