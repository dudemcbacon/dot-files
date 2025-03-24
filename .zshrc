#
# .zshrc --> Universal Globals for ZSH
# Props to github.com/jdavis who inspired much of this.
#

# For sudo-ing aliases
# https://wiki.archlinux.org/index.php/Sudo#Passing_aliases alias sudo='sudo '

# Ensure languages are set
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

source ~/.nwearc

# Misc. config variables
export TERM="xterm-256color"
export EDITOR="nvim"
export HISTFILESIZE=32768
export HISTSIZE=32768
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export GREP_OPTIONS="--color=auto"
export MANPAGER="less -X"
export DEV_DIR=${HOME}/development

# TMUX Options
export ZSH_TMUX_AUTOSTART=false

# Detect OS
UNAME=`uname`

# Fallback info
CURRENT_OS='Linux'
DISTRO=''

if [[ $UNAME == 'Darwin' ]]; then
  CURRENT_OS='OS X'
elif [[ $UNAME == 'CYGWIN' ]]; then
  CURRENT_OS='Cygwin'
else
  # Must be Linux, determine distro
  # Work in progress, so far CentOS is the only Linux distro I have needed to
  # determine
  if [[ -f /etc/redhat-release ]]; then
    # CentOS or Redhat?
    if grep -q "CentOS" /etc/redhat-release; then
      DISTRO='CentOS'
    else
      DISTRO='RHEL'
    fi
  fi
fi

# Source universal aliases:
. ~/.aliases

# OS specific aliases, functions, variables
if [[ `uname` == 'Darwin' ]]; then
  . ~/.macrc
elif [[ `uname` == 'Linux' ]]; then
  . ~/.linuxrc
fi

# oh-my-zsh config
ZSH=${DEV_DIR}/.oh-my-zsh
ZSH_CUSTOM=${DEV_DIR}/dot-files/oh-my-zsh-custom

# Universal plugins
plugins=(docker tmux)

# OS specifig plugins
if [[ $CURRENT_OS == 'OS X' ]]; then
  plugins+=(macos brew iterm2)
elif [[ $CURRENT_OS == 'Linux' ]]; then
  plugins+=()
  if [[ $DISTRO == 'CentOS' ]]; then
    plugins+=(centos)
  fi
elif [[ $CURRENT_OS == 'Cygwin' ]]; then
  plugins+=(cygwin)
fi

source $ZSH/oh-my-zsh.sh

zstyle :omz:plugins:ssh-agent agent-forwarding on

if [ -e ~/.asdf/plugins/java/set-java-home.zsh ]; then
  . ~/.asdf/plugins/java/set-java-home.zsh
fi

if [ -e ~/.newrelic_rc ]; then
  source ~/.newrelic_rc
fi

export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# For yadm encrypt to work correctly:
export GPG_TTY=$(tty)
