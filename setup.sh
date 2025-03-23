#!/bin/bash

set -e

echo "Setting up environment..."

LOGFILE="$HOME/setup_log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

NVIM_SOURCE="$HOME/git/configs/nvim-linux64"
DOTFILES_SOURCE="$HOME/git/configs/dotfiles"


# Install dependencies

install_neovim() {
    echo "Installing neovim..."

    if [ ! -d "$NVIM_SOURCE" ]; then
        echo "Error: Neovim source directory not found at $NVIM_SOURCE"
        return 1
    fi

    mkdir -p "$HOME/.config"

    cp -r "$NVIM_SOURCE" "$HOME/"

    if [ -d "$DOTFILES_SOURCE/nvim" ]; then
        cp -r "$DOTFILES_SOURCE/nvim" "$HOME/.config/" 
    else
        echo "Warning: Neovim config not found at $DOTFILES_SOURCE/nvim"
    fi

    echo 'export PATH="$PATH:$HOME/nvim-linux64/bin"' >> "$HOME/.bashrc"
    echo 'alias nv="nvim"' >> "$HOME/.bashrc"
}


config_tmux() {
    echo "Configuring tmux..."

    if [ -f "$DOTFILES_SOURCE/.tmux.conf" ]; then
        cp "$DOTFILES_SOURCE/.tmux.conf" "$HOME/"
    else
        echo "Warning: Tmux config not found at $DOTFILES_SOURCE/.tmux.conf"
    fi
}


install_fzf() {
    echo "Installing fzf..."

    if [! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
        eval "$(fzf --bash)"
    else
        echo "Warning: fzf already installed at $HOME/.fzf"
    fi

    if [ ! -d "$HOME/git-fuzzy" ]; then
        git clone https://github.com/bigH/git-fuzzy.git "$HOME/git-fuzzy"
        echo 'export PATH="$HOME/git-fuzzy/bin:$PATH"' >> "$HOME/.bashrc"
    else
        echo "Warning: git-fuzzy already installed at $HOME/git-fuzzy"
    fi
}


install_ruff_uv() {
    echo "Installing ruff and uv..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

    echo 'eval "$(uv generate-shell-completion bash)"' >> "$HOME/.bashrc"
   
    curl -LsSf https://astral.sh/ruff/install.sh | sh
}

main() {
    install_neovim
    config_tmux
    install_fzf
    install_ruff_uv

    echo "Setup complete! Please log out and log back in to apply all changes."
}

main
