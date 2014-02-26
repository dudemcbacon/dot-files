#
#	Here be my shell stuff
#

export EDITOR="nano"
export HISTFILESIZE=32768
export HISTSIZE=32768

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export GREP_OPTIONS="--color=auto"

export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export GOPATH=~/gopath

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Source non-os specific aliases
. ~/.aliases

# Source .nikerc for Nike specific functions
#. ~/.nikerc

# Apply os-specific aliases, functions, and variables
if [[ `uname` == 'Darwin' ]]; then
	. ~/.macrc
fi

if [[ `uname` == 'Linux' ]]; then
	. ~/.linuxrc
fi

# This PATH is the boss PATH
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/heroku/bin:/usr/local/opt/ruby/bin:$PATH"
