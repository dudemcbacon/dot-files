#!/bin/sh
#
# 1a. Make sure zsh is installed.
# 1b. Make sure git is installed.
# 2. Install oh-my-zsh from GitHub
# 3. Link appropriate dot-files
#
DEV_DIR = "${HOME}/development"

zsh --version 2> /dev/null
if [ $? -eq 127 ]; then
  echo "Install ZSH!~"
fi

git --version 2> /dev/null
if [ $? -eq 127 ]; then
  echo "Install Git!~"
fi

# Install oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git $DEV_DIR/.oh-my-zsh

# Link dot-files
ln -s .aliases ~/
ln -s .config ~/
ln -s .gemrc ~/
ln -s .git ~/
ln -s .linuxrc ~/
ln -s .macrc ~/
ln -s .nikerc ~/
ln -s .profile ~/
ln -s .tmux.conf ~/
ln -s .zshrc ~/

# Change shell to zsh
chsh -s /bin/zsh