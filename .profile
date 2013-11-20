#
#	Here be my shell stuff
#

export PATH="/usr/local/heroku/bin:/usr/local/opt/ruby/bin:$PATH"

export CLICOLOR=1
export EDITOR="nano"
export HISTFILESIZE=
export HISTSIZE=
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export GOPATH=~/gopath

# Source non-os specific aliases
. ~/.aliases

# Source .nikerc for Nike specific functions
. ~/.nikerc

# Apply os-specific aliases, functions, and variables
if [[ `uname` == 'Darwin' ]]; then
	. ~/.macrc
fi

if [[ `uname` == 'Linux' ]]; then
	. ~/.linuxrc
fi
