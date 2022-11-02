#!/bin/bash
#
# 1a. Make sure zsh is installed.
# 1b. Make sure git is installed.
# 1c. Make sure tmux is installed
# 1d. Make sure pip is installed.
# 2. Install oh-my-zsh from GitHub
# 3. Link appropriate dot-files
#
set -e

DEV_DIR="${HOME}/development"

zsh --version 2>&1 /dev/null
if [ $? -eq 127 ]; then
  echo "Install ZSH!~"
  exit 1
fi

git --version 2>&1 /dev/null
if [ $? -eq 127 ]; then
  echo "Install Git!~"
  exit 1
fi

tmux -V 2>&1 /dev/null
if [ $? -eq 127 ]; then
  echo "Install Tmux!~"
  exit 1
fi

nvim -v 2>&1 /dev/null
if [ $? -eq 127 ]; then
  echo "Install nvim!~"
  exit 1
fi

direnv version
if [ $? -eq 127 ]; then
  echo "Install direnv!~"
  exit 1
fi

# Install powerline-fonts
if [ ! -e ${HOME}/.fonts-installed ]; then
  echo "Installing powerline-fonts..."
  git clone https://github.com/powerline/fonts.git ${DEV_DIR}/fonts --depth=1
  if [ $? -ne 0 ]; then
    echo "Problem installing powerline-fonts"
    exit 1
  fi
  ${DEV_DIR}/fonts/install.sh
  rm -rf ${DEV_DIR}/fonts
  touch ~/.fonts-installed
fi

# Install tpm
if [ ! -e ${HOME}/.tmux/plugins/tpm ]; then
  echo "Installing tpm..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  if [ $? -eq 128 ]; then
    echo "Problem installing tpm."
    exit 1
  fi
fi

# Install oh-my-zsh
if [ ! -e ${DEV_DIR}/.oh-my-zsh ]; then
  echo "Installing oh-my-zsh..."
  git clone https://github.com/robbyrussell/oh-my-zsh.git ${DEV_DIR}/.oh-my-zsh
  if [ $? -eq 128 ]; then
    echo "Problem installing oh-my-zsh. Do you need to set a proxy?"
    exit 1
  fi
fi

# Install asdf
if [ ! -e ${HOME}/.asdf ]; then
  echo "Installing asdf..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
  if [ $? -eq 128 ]; then
    echo "Problem installing asdf"
    exit 1
  fi
fi

# Prep vim-plug
if [ ! -e ${HOME}/.local/share/nvim/site/autoload/plug.vim ]; then
  echo 'Installing vim-plug...'
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if [ $? -eq 128 ]; then
    echo "Problem installing vim-plug"
  fi
fi

# Prep starship
if [ ! -e /usr/local/bin/starship ]; then
  echo 'Installing starship...'
  curl -sS https://starship.rs/install.sh | sh
  if [ $? -eq 128 ]; then
    echo "Problem installing starship"
    exit 1
  fi
fi

# Change shell to zsh
sudo chsh -s /bin/zsh

echo "Don't forget add a powerline font.'"
echo "Don't forget to run :PlugInstall in vim"
echo "Don't forget to run :PlugUpdate in vim"
echo "Don't forget to run :PlugClean in vim"
echo "Don't forget to run :CocInstall coc-json coc-tsserver in vim"
