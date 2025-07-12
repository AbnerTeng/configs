#!/bin/bash

sys_os=$(uname -m) # x86_64 / arm64

set -e

echo "Setting up environment..."

LOGFILE="$HOME/setup_log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

DOTFILES_SOURCE="$HOME/git/configs/dotfiles"

# Install dependencies

download_and_install_neovim() {
  echo "Downloading neovim..."

  cd $HOME

  if [ "$sys_os" == "arm64" ]; then
    wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-macos-arm64.tar.gz
    xattr -c ./nvim-macos-arm64.tar.gz && tar xzvf nvim-macos-arm64.tar.gz
    mv nvim-macos-arm64 nv
  else
    wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
    tar xzvf nvim-linux-x86_64.tar.gz
    mv nvim-linux-x86_64 nv
  fi

  echo "Download complete."

  echo 'export PATH="$HOME/nv/bin:$PATH"' >> "$HOME"/.bashrc
  source "$HOME/.bashrc"

  if nvim --version >/dev/null 2>&1; then
    echo "Neovim is already installed."
  else
    echo "Neovim installation failed. Please check the logs."
    exit 1
  fi

  echo "Installing LazyVim..."

  mkdir -p "$HOME"/.config
  git clone https://github.com/LazyVim/starter "$HOME"/.config/nvim && rm -rf "$HOME"/.config/nvim/.git

  echo 'alias nv="nvim"' >> "$HOME"/.bashrc
  source "$HOME"/.bashrc

  if [ -d "$DOTFILES_SOURCE"/nvim ]; then
    cp -r "$DOTFILES_SOURCE"/nvim "$HOME"/.config/
  else
    echo "Warning: Neovim config not found at $DOTFILES_SOURCE/nvim"
  fi
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

  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/.fzf
    "$HOME/.fzf/install" --all
    eval "$(fzf --bash)"
  else
    echo "Warning: fzf already installed at $HOME/.fzf"
  fi

  if [ ! -d "$HOME"/git-fuzzy ]; then
    git clone https://github.com/bigH/git-fuzzy.git "$HOME"/git-fuzzy
    echo 'export PATH="$HOME/git-fuzzy/bin:$PATH"' >> "$HOME"/.bashrc
  else
    echo "Warning: git-fuzzy already installed at $HOME/git-fuzzy"
  fi
}

install_ruff_uv() {
  echo "Installing ruff and uv..."

  curl -LsSf https://astral.sh/uv/install.sh | sh

  echo 'eval "$(uv generate-shell-completion bash)"' >>"$HOME"/.bashrc

  curl -LsSf https://astral.sh/ruff/install.sh | sh

  echo "export PATH='$HOME/.local/bin:$PATH'" >>"$HOME"/.bashrc
  source "$HOME"/.bashrc
}

install_nvtop() {
  if [ "$sys_os" == "x86_64" ]; then
    cd ~
    wget https://github.com/Syllo/nvtop/releases/donwload/latest/nvtop-x86_64.AppImage
    chmod +x u+x nvtop-x86_64.AppImage
    echo 'alias nvtop="$HOME/nvtop-x86_64.AppImage"' >> "$HOME"/.bashrc
    source "$HOME"/.bashrc
  else
    echo "nvtop is not supported on arm64 architecture."
  fi
}

install_yq() {
  echo "Installing yq..."

  if [ "$sys_os" == "arm64" ]; then
    wget https://github.com/mikefarah/yq/releases/download/latest/yq_darwin_arm64 -O "$HOME"/.local/bin/yq
  else
    wget https://github.com/mikefarah/yq/releases/download/latest/yq_linux_amd64 -O "$HOME"/.local/bin/yq
  fi

  echo "Donwloading yq complete."

  chmod +x "$HOME/.local/bin/yq"

  if ! grep -q 'export PATH=.*.local/bin' "$HOME"/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME"/.bashrc
    source "$HOME"/.bashrc
  fi

  if yq --version >/dev/null 2>&1; then
    echo "yq is installed successfully."
  else
    echo "yq installation failed. Please check the logs."
    exit 1
  fi
}

main() {
  download_and_install_neovim
  config_tmux
  install_fzf
  install_ruff_uv
  install_nvtop
  install_yq

  echo "Setup complete! Please log out and log back in to apply all changes."
}

main
