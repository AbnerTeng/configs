#!/bin/bash

sys_os=$(uname -m)

if [ "$sys_os" != "x86_64" ] && [ "$sys_os" != "arm64" ]; then
  echo "Unsupported architecture: $sys_os"
  exit 1
elif [ "$sys_os" == "arm64" ]; then
  echo "Installing homebrew for arm64 architecture..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install wget curl git python

  if python --version >/dev/null 2>&1; then
    echo "Python is installed successfully."
  else
    echo "Python installation failed."
    exit 1
  fi

else
  echo "x86_64 may have pre-installed basic tools."
fi