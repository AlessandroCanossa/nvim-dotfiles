#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # dotfiles dir, wherever it was cloned

load_env() {
  [ -f "$1" ] || return 0
  set -a          # export every variable defined while sourcing
  . "$1"
  set +a
}

load_env "$DIR/.env"

sudo apt update
sudo apt install -y wget curl software-properties-common python3-venv xsel xclip fzf wl-clipboard ripgrep &>/dev/null

pushd /tmp &>/dev/null

echo "-- Installing neovim"
wget "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" &>/dev/null
tar xzf nvim-linux-x86_64.tar.gz
cp -R nvim-linux-x86_64/. ~/.local/
rm -r nvim-linux-x86_64 nvim-linux-x86_64.tar.gz

if [ ! -w /nvim-data ]; then
  sudo chown -R "$(id -u):$(id -g)" /nvim-data
fi

echo "-- Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "-- Installing npm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
NVM_DIR=~/.nvm
. "$NVM_DIR/nvm.sh" && nvm install --lts

echo "-- Installing lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" &>/dev/null
tar xf lazygit.tar.gz lazygit
install lazygit ~/.local/bin
rm -rf lazygit lazygit.tar.gz

popd &>/dev/null
