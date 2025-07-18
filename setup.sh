#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration and Setup ---

# Determine the script's absolute directory to locate other files.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
DOTFILES_SOURCE="$SCRIPT_DIR/dotfiles"
LOGFILE="$HOME/setup_log.txt"

# Redirect stdout and stderr to a log file and the console.
exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting setup process. Log will be saved to $LOGFILE"
echo "Dotfiles source directory: $DOTFILES_SOURCE"

# --- System Detection ---

OS=$(uname -s)   # Linux, Darwin (macOS)
ARCH=$(uname -m) # x86_64, arm64
SHELL_NAME=$(basename "$SHELL")
RC_FILE="$HOME/.${SHELL_NAME}rc"

echo "Detected OS: $OS, Architecture: $ARCH, Shell: $SHELL_NAME"
echo "Using shell configuration file: $RC_FILE"

# Create the rc file if it doesn't exist
touch "$RC_FILE"

# --- Helper Functions ---

# Function to add a line to the shell configuration file if it's not already there.
add_to_rc() {
  local line="$1"
  if ! grep -qF -- "$line" "$RC_FILE"; then
    echo "Adding '$line' to $RC_FILE"
    echo -e "
# Added by setup.sh
$line" >>"$RC_FILE"
  else
    echo "Line already exists in $RC_FILE: '$line'"
  fi
}

# --- Installation Functions ---

download_and_install_neovim() {
  echo "Setting up Neovim..."
  cd "$HOME"

  local nvim_url=""
  local nvim_archive=""
  local nvim_dir=""

  if [ "$OS" = "Darwin" ] && [ "$ARCH" = "arm64" ]; then
    nvim_url="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-macos-arm64.tar.gz"
    nvim_archive="nvim-macos-arm64.tar.gz"
    nvim_dir="nvim-macos-arm64"
  elif [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    nvim_url="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz"
    nvim_archive="nvim-linux-x86_64.tar.gz"
    nvim_dir="nvim-linux-x86_64"
  else
    echo "Warning: Neovim pre-built binary not available for $OS-$ARCH. Skipping Neovim installation."
    return
  fi

  echo "Downloading Neovim from $nvim_url..."
  wget "$nvim_url"

  echo "Extracting $nvim_archive..."
  if [ "$OS" = "Darwin" ]; then
    xattr -c "./$nvim_archive" # Remove quarantine attribute on macOS
  fi
  tar xzvf "$nvim_archive"

  # Clean up old installation and move new one
  rm -rf ./nv
  mv "./$nvim_dir" ./nv
  rm "./$nvim_archive"

  echo "Neovim downloaded and extracted to $HOME/nv."

  add_to_rc 'export PATH="$HOME/nv/bin:$PATH"'
  add_to_rc 'alias nv="nvim"'

  echo "Installing LazyVim starter configuration..."
  if [ -d "$HOME/.config/nvim" ]; then
    echo "Found existing nvim config, creating a backup at $HOME/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi
  mkdir -p "$HOME/.config"
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" && rm -rf "$HOME/.config/nvim/.git"

  echo "Copying custom Neovim configuration..."
  if [ -d "$DOTFILES_SOURCE/nvim" ]; then
    # Use rsync to avoid overwriting the whole directory, just copy contents
    rsync -av --progress "$DOTFILES_SOURCE/nvim/" "$HOME/.config/nvim/"
  else
    echo "Warning: Custom Neovim config not found at $DOTFILES_SOURCE/nvim"
  fi
}

config_tmux() {
  echo "Configuring tmux..."
  if [ -f "$DOTFILES_SOURCE/.tmux.conf" ]; then
    cp "$DOTFILES_SOURCE/.tmux.conf" "$HOME/"
    echo "Copied .tmux.conf to $HOME"
    tmux set -g prefix C-a
  else
    echo "Warning: Tmux config not found at $DOTFILES_SOURCE/.tmux.conf"
  fi
}

install_fzf() {
  echo "Installing fzf..."
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"

    "$HOME/.fzf/install" --bin
    add_to_rc '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'
    add_to_rc '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
  else
    echo "fzf is already installed at $HOME/.fzf"
  fi

  echo "Installing git-fuzzy..."
  if [ ! -d "$HOME/git-fuzzy" ]; then
    git clone https://github.com/bigH/git-fuzzy.git "$HOME/git-fuzzy"
    add_to_rc 'export PATH="$HOME/git-fuzzy/bin:$PATH"'
  else
    echo "git-fuzzy is already installed at $HOME/git-fuzzy"
  fi
}

install_ruff_uv() {
  echo "Installing uv and ruff..."

  mkdir -p "$HOME/.local/bin"
  add_to_rc 'export PATH="$HOME/.local/bin:$PATH"'

  if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    add_to_rc 'source <(uv generate-shell-completion zsh)'
    add_to_rc 'source <(uv generate-shell-completion bash)'
  else
    echo "uv is already installed."
  fi

  if ! command -v ruff &>/dev/null; then
    echo "Installing ruff..."
    "$HOME/.local/bin/uv" pip install ruff
  else
    echo "ruff is already installed."
  fi
}

install_nvtop() {
  echo "Installing nvtop..."
  if [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    cd "$HOME"
    local nvtop_url="https://github.com/Syllo/nvtop/releases/download/3.2.0/nvtop-3.2.0-x86_64.AppImage"
    local nvtop_appimage="nvtop-3.2.0-x86_64.AppImage"

    wget -O "$nvtop_appimage" "$nvtop_url"
    chmod u+x "$nvtop_appimage"

    add_to_rc "alias nvtop=''''$HOME/$nvtop_appimage''''"
    echo "nvtop installed."
  else
    echo "Skipping nvtop: Not supported on $OS-$ARCH."
  fi
}

install_yq() {
  echo "Installing yq..."
  mkdir -p "$HOME/.local/bin"
  local yq_path="$HOME/.local/bin/yq"
  local yq_url=""

  if [ "$OS" = "Darwin" ] && [ "$ARCH" = "arm64" ]; then
    yq_url="https://github.com/mikefarah/yq/releases/download/v4.46.1/yq_darwin_arm64"
  elif [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    yq_url="https://github.com/mikefarah/yq/releases/download/v4.46.1/yq_linux_amd64"
  else
    echo "Warning: yq pre-built binary not available for $OS-$ARCH. Skipping yq installation."
    return
  fi

  echo "Downloading yq from $yq_url..."
  wget -O "$yq_path" "$yq_url"
  chmod +x "$yq_path"

  add_to_rc 'export PATH="$HOME/.local/bin:$PATH"'
  echo "yq installation complete."
  "$yq_path" --version
}

# --- Main Execution ---

main() {
  bash "$SCRIPT_DIR/pre-check.sh"
  download_and_install_neovim
  config_tmux
  install_fzf
  install_ruff_uv
  # install_nvtop # Commented out as in original
  install_yq

  echo "----------------------------------------------------------------"
  echo "Setup complete!"
  echo "Please run 'source $RC_FILE' or restart your shell to apply all changes."
  echo "----------------------------------------------------------------"
}

main

