#
#	Here be my shell stuff
#

alias ls='ls -lha -G' 

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias listen="lsof -i -n | grep 'LISTEN'"


# stat cmds
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias cpuinfo2='less /proc/cpuinfo'


PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] ' 

export PATH="/usr/local/heroku/bin:/usr/local/opt/ruby/bin:$PATH"

export CLICOLOR=1
export EDITOR="nano"
export HISTFILESIZE=
export HISTSIZE=
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export GOPATH=~/gopath

# Source .nikerc for Nike specific functions
. ~/.nikerc

# Determine OS and apply specific functions
if [ `uname` == 'Darwin' ]; then
	. ~/.macrc
elif [`uname` == 'Linux' ]; then
	. ~/.linuxrc
fi
