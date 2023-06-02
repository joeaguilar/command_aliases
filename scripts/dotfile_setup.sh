#!/bin/bash

if ! [ -x "$(command -v git)" ]; then
  if [ -x "$(command -v apt-get)" ]; then
    apt-get update
    apt-get install git -y
  fi
  if ! [ -x "$(command -v git)" ]; then
    printf "\nThis script requires git!\n"
    exit 1
  fi
fi

git clone https://github.com/joeaguilar/command_aliases.git ~/dotfiles

make_symlink() {
  if [ -e ~/$1 ]; then
    echo "Found existing file, created backup: ~/${1}.bak"
    mv ~/$1 ~/$1.bak
  fi
  ln -sf ~/command_aliases/$1 ~/$1;
}

make_vs_code_symlink() {
    VS_CODE_FILE="~/Library/Application\ Support/Code/User/${1}"
    if [ -e $VS_CODE_FILE ]; then
        echo "Found existing file, created backup ~/${$VS_CODE_FILE}.bak"
        mv $VS_CODE_FILE "$VS_CODE_FILE.bak"
    fi
    ln -sf ~/command_aliases/vscode/$1 $VS_CODE_FILE
}

# make_symlink .profile
make_symlink .bashrc
make_symlink .bash_aliases
make_symlink .bash_profile
make_symlink .bash_prompt


make_symlink .gitconfig
make_symlink .gitignore
# make_symlink .gitcompletion.bash

# make_symlink .kubecompletion.bash
make_symlink .curlrc
# make_symlink .nvmrc

# make_symlink .tmux.conf

#VS Code symlinks
make_vs_code_symlink settings.json

