#!/bin/bash

# --- Helper Functions ---

check_dependencies() {
  echo "Checking for dependencies..."
  local missing_deps=0
  for cmd in git wget curl tar; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Error: Required command '$cmd' is not installed." >&2
      missing_deps=$((missing_deps + 1))
    fi
  done

  if [ "$missing_deps" -gt 0 ]; then
    echo "Please install the missing dependencies and run the script again." >&2
    exit 1
  fi
  echo "All dependencies are satisfied."
}

sys_os=$(uname -m)

if [ "$sys_os" != "x86_64" ] && [ "$sys_os" != "arm64" ]; then
  echo "Unsupported architecture: $sys_os"
  exit 1
elif [ "$sys_os" == "arm64" ]; then
  echo "Installing homebrew for arm64 architecture..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install wget curl git python bc

  if python --version >/dev/null 2>&1; then
    echo "Python is installed successfully."
  else
    echo "Python installation failed."
    exit 1
  fi

else
  echo "x86_64 may have pre-installed basic tools."
fi

check_dependencies
