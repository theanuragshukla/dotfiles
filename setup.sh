#!/bin/bash

programs=("fish" "ripgrep" "zoxide" "exa" "git" "curl" "stow" "wget" "ninja-build" "gettext" "cmake" "unzip")

sudo apt update
sudo apt install -y "${programs[@]}"

chsh -s $(which fish)

git clone https://github.com/theanuragshukla/dotfiles

mv ~/.config ~/.config.bak
mkdir -p ~/.config

cd dotfiles

stow --target ~/.config .

mkdir -p ~/setup
cd ~/setup

git clone https://github.com/neovim/neovim

cd neovim

make CMAKE_BUILD_TYPE=RelWithDebInfo

ls

cd build

cpack -G DEB

sudo dpkg -i --force-overwrite nvim-linux64.deb

mkdir -p ~/obsidian

cd ~/setup
curl -sS https://starship.rs/install.sh | sh

cd ~/setup

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

~/.fzf/install

cd ~/setup

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

curl -L https://get.oh-my.fish | fish

omf install nvm

nvm install --latest

npm install -g typescript typescript-language-server

