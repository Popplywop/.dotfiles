#!/bin/bash

# Dotfiles Installation Script
# This script installs all dependencies for a fresh WSL/Linux build

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# ============================================================================
# Core Packages
# ============================================================================
install_core_packages() {
    print_header "Installing Core Packages"

    sudo apt update
    sudo apt install -y \
        git \
        stow \
        curl \
        wget \
        unzip \
        build-essential \
        cmake \
        gettext \
        ninja-build \
        bash-completion \
        ca-certificates \
        gnupg

    print_success "Core packages installed"
}

# ============================================================================
# Neovim (latest from tarball)
# ============================================================================
install_neovim() {
    print_header "Installing Neovim"

    if command_exists nvim; then
        print_warning "Neovim already installed: $(nvim --version | head -n1)"
        return
    fi

    cd ~ \
    && git clone https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && sudo make install

    print_success "Neovim installed to /usr/local"
}

# ============================================================================
# Neovim Dependencies (ripgrep, fd, tree-sitter)
# ============================================================================
install_nvim_deps() {
    print_header "Installing Neovim Dependencies"

    sudo apt install -y ripgrep fd-find

    # Create symlink for fd (Ubuntu names it fdfind)
    if command_exists fdfind && ! command_exists fd; then
        mkdir -p ~/.local/bin
        ln -sf $(which fdfind) ~/.local/bin/fd
    fi

    print_success "Neovim dependencies installed (ripgrep, fd)"
}

# ============================================================================
# Oh My Posh
# ============================================================================
install_oh_my_posh() {
    print_header "Installing Oh My Posh"

    if command_exists oh-my-posh; then
        print_warning "Oh My Posh already installed"
        return
    fi

    curl -s https://ohmyposh.dev/install.sh | bash -s

    # Download catppuccin theme
    mkdir -p ~/.cache/oh-my-posh/themes
    wget -q https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json \
        -O ~/.cache/oh-my-posh/themes/catppuccin_mocha.omp.json

    print_success "Oh My Posh installed"
}

# ============================================================================
# Zoxide
# ============================================================================
install_zoxide() {
    print_header "Installing Zoxide"

    if command_exists zoxide; then
        print_warning "Zoxide already installed"
        return
    fi

    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    print_success "Zoxide installed"
}

# ============================================================================
# FNM (Fast Node Manager)
# ============================================================================
install_fnm() {
    print_header "Installing FNM (Fast Node Manager)"

    if [ -d "$HOME/.local/share/fnm" ]; then
        print_warning "FNM already installed"
        return
    fi

    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell

    # Install latest LTS Node
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts

    print_success "FNM installed with latest LTS Node"
}

# ============================================================================
# PNPM
# ============================================================================
install_pnpm() {
    print_header "Installing PNPM"

    if command_exists pnpm; then
        print_warning "PNPM already installed"
        return
    fi

    curl -fsSL https://get.pnpm.io/install.sh | sh -

    print_success "PNPM installed"
}

# ============================================================================
# vtsls (TypeScript LSP)
# ============================================================================
install_vtsls() {
    print_header "Installing vtsls (TypeScript LSP)"

    if command_exists vtsls; then
        print_warning "vtsls already installed"
        return
    fi

    # Ensure npm is available (from fnm)
    if [ -d "$HOME/.local/share/fnm" ]; then
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env)"
    fi

    if ! command_exists npm; then
        print_error "npm not found. Please install Node.js first (option 5)"
        return 1
    fi

    npm install -g @vtsls/language-server

    print_success "vtsls installed"
}

# ============================================================================
# vscode-langservers-extracted (HTML/CSS/JSON LSPs)
# ============================================================================
install_vscode_langservers() {
    print_header "Installing vscode-langservers-extracted (HTML/CSS/JSON LSPs)"

    if command_exists html-languageserver; then
        print_warning "vscode-langservers-extracted already installed"
        return
    fi

    # Ensure npm is available (from fnm)
    if [ -d "$HOME/.local/share/fnm" ]; then
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env)"
    fi

    if ! command_exists npm; then
        print_error "npm not found. Please install Node.js first (option 5)"
        return 1
    fi

    npm install -g vscode-langservers-extracted

    print_success "vscode-langservers-extracted installed"
}

# ============================================================================
# Lua Language Server
# ============================================================================
install_lua_language_server() {
    print_header "Installing Lua Language Server"

    if command_exists lua-language-server; then
        print_warning "Lua Language Server already installed"
        return
    fi

    LUA_LS_VERSION="3.13.5"
    LUA_LS_DIR="$HOME/.local/share/lua-language-server"
    LUA_LS_URL="https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz"

    mkdir -p "$LUA_LS_DIR"
    curl -sSL "$LUA_LS_URL" | tar -xz -C "$LUA_LS_DIR"

    # Create symlink in ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    ln -sf "$LUA_LS_DIR/bin/lua-language-server" "$HOME/.local/bin/lua-language-server"

    print_success "Lua Language Server installed"
}

# ============================================================================
# .NET SDK
# ============================================================================
install_dotnet() {
    print_header "Installing .NET SDK"

    if [ -d "$HOME/.dotnet" ]; then
        print_warning ".NET already installed"
        return
    fi

    # Install using Microsoft's install script
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS --install-dir "$HOME/.dotnet"

    print_success ".NET SDK installed to ~/.dotnet"
}

# ============================================================================
# Roslyn Language Server (C# LSP for Neovim)
# ============================================================================
install_roslyn_lsp() {
    print_header "Installing Roslyn Language Server"

    ROSLYN_DIR="$HOME/.local/share/nvim/Microsoft.CodeAnalysis.LanguageServer"
    DLL_PATH="$ROSLYN_DIR/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll"

    if [ -f "$DLL_PATH" ]; then
        print_warning "Roslyn Language Server already installed"
        return
    fi

    mkdir -p "$ROSLYN_DIR"
    unzip -o $HOME/.dotfiles/assets/*.nupkg -d "$ROSLYN_DIR"

    # Make the DLL executable (needed for some setups)
    chmod +x "$DLL_PATH"

    print_success "Roslyn Language Server installed"
}

# ============================================================================
# WezTerm
# ============================================================================
install_wezterm() {
    print_header "Installing WezTerm"

    if command_exists wezterm; then
        print_warning "WezTerm already installed"
        return
    fi

    # For Ubuntu/Debian
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update
    sudo apt install -y wezterm

    print_success "WezTerm installed"
}

# ============================================================================
# Nerd Fonts (JetBrainsMono)
# ============================================================================
install_nerd_fonts() {
    print_header "Installing JetBrainsMono Nerd Font"

    FONT_DIR="$HOME/.local/share/fonts"

    if [ -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        print_warning "JetBrainsMono Nerd Font already installed"
        return
    fi

    # Use oh-my-posh if available
    if command_exists oh-my-posh; then
        oh-my-posh font install JetBrainsMono
        print_success "JetBrainsMono Nerd Font installed via oh-my-posh"
        return
    fi

    # Fallback to manual installation
    mkdir -p "$FONT_DIR"
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
    fc-cache -fv

    print_success "JetBrainsMono Nerd Font installed"
}

# ============================================================================
# Stow Bash (run first to get shell config)
# ============================================================================
stow_bash() {
    print_header "Stowing Bash Config"

    cd "$HOME/.dotfiles"

    # Use --adopt to overwrite existing .bashrc
    if [ -d "bash" ]; then
        stow bash --adopt
        source ~/.bashrc
        print_success "Bash config stowed"
    else
        print_warning "bash directory not found"
    fi
}

# ============================================================================
# Stow Dotfiles
# ============================================================================
stow_dotfiles() {
    print_header "Stowing Dotfiles"

    cd "$HOME/.dotfiles"

    # List of packages to stow (bash already done earlier)
    packages=(
        "nvim"
        "wezterm"
        "ohmyposh"
    )

    for pkg in "${packages[@]}"; do
        if [ -d "$pkg" ]; then
            echo "Stowing $pkg..."
            stow -v --restow "$pkg" 2>/dev/null || print_warning "Failed to stow $pkg"
        fi
    done

    print_success "Dotfiles stowed"
}

# ============================================================================
# Main Menu
# ============================================================================
show_menu() {
    echo ""
    echo "Dotfiles Installation Script"
    echo "============================="
    echo ""
    echo "1)  Install ALL (recommended for fresh system)"
    echo "2)  Install Core packages only"
    echo "3)  Install Neovim + dependencies (lua-language-server)"
    echo "4)  Install Shell tools (oh-my-posh, zoxide)"
    echo "5)  Install Node.js ecosystem (fnm, pnpm, vtsls, html/css LSPs)"
    echo "6)  Install .NET SDK + Roslyn LSP"
    echo "7)  Install WezTerm"
    echo "8)  Install Nerd Fonts"
    echo "9) Stow dotfiles"
    echo "0)  Exit"
    echo ""
}

install_all() {
    install_core_packages
    stow_bash
    install_neovim
    install_nvim_deps
    install_lua_language_server
    install_oh_my_posh
    install_zoxide
    install_fnm
    install_pnpm
    install_vtsls
    install_vscode_langservers
    install_dotnet
    install_roslyn_lsp
    install_wezterm
    install_nerd_fonts
    stow_dotfiles

    print_header "Installation Complete!"
    echo "Please restart your terminal or run: source ~/.bashrc"
}

# ============================================================================
# Main
# ============================================================================
main() {
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please don't run this script as root"
        exit 1
    fi

    # If arguments provided, run non-interactively
    if [ "$1" = "--all" ]; then
        install_all
        exit 0
    fi

    # Interactive menu
    while true; do
        show_menu
        read -p "Select option: " choice

        case $choice in
            1)  install_all ;;
            2)  install_core_packages ;;
            3)  install_neovim; install_nvim_deps; install_lua_language_server ;;
            4)  install_oh_my_posh; install_zoxide ;;
            5)  install_fnm; install_pnpm; install_vtsls; install_vscode_langservers ;;
            6)  install_dotnet; install_roslyn_lsp ;;
            7)  install_wezterm ;;
            8)  install_nerd_fonts ;;
            9) stow_dotfiles ;;
            0)  echo "Bye!"; exit 0 ;;
            *)  print_error "Invalid option" ;;
        esac
    done
}

main "$@"
