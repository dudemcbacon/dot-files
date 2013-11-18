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

# misc
alias ls='ls -lha -G' 
alias listen="lsof -i -n | grep 'LISTEN'"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# git
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'

# stat cmds
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias cpuinfo2='less /proc/cpuinfo'

# Source .nikerc for Nike specific functions
. ~/.nikerc

# Determine OS and apply specific functions
if [[ `uname` == 'Darwin' ]]; then
	. ~/.macrc
fi

if [[ `uname` == 'Linux' ]]; then
	. ~/.linuxrc
fi
