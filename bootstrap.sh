#!/bin/bash
#
# 1a. Make sure zsh is installed.
# 1b. Make sure git is installed.
# 1c. Make sure tmux is installed
# 1d. Make sure pip is installed.
# 2. Install oh-my-zsh from GitHub
# 3. Link appropriate dot-files
#
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

pip --version 2>&1 /dev/null
if [ $? -eq 127 ]; then
  echo "Install pip!~"
  exit 1
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

# Install powerline
pip show powerline | grep powerline 2>&1
if [ $? -eq 1 ]; then
  echo "Cloning powerline..."
  git clone https://github.com/Lokaltog/powerline.git ${DEV_DIR}/powerline
  cd ${DEV_DIR}/powerline
  echo "Installing powerline..."
  python setup.py install --user
  cd ${DEV_DIR}/dot-files
  if [ $? -eq 128 ]; then
    echo "Problem installing powerline. Do you need to set a proxy?"
    exit 1
  fi
fi

# Link dot-files
for f in .*
do
  if [ $f != "." ] && [ $f != ".." ] && [ $f != ".git" ]; then
    FILE=${HOME}/${f}
    GIT_FILE=`pwd`/${f}
    # Does a real (non-symbolic) file exist?
    if [ -e $FILE ]; then
      echo "Replace $FILE? [y/N]"
      read answer
      if [ "$answer" == "y" ]; then
        echo "Replacing $f..."
        mv $FILE $FILE.old
        ln -s $GIT_FILE ~/
      fi
    elif [ -h $FILE ]; then
      echo "$f is already linked."
    else
      echo "Linking $f..."
      ln -s $GIT_FILE ~/
    fi
  fi
done

# Change shell to zsh
chsh -s /bin/zsh
