# MacPorts Installer addition on 2013-04-16_at_10:49:23: adding an appropriate PATH variable for use with MacPorts.
#export PATH=/usr/local/opt/ruby/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:~/bin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

# PS1
PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] ' 

alias ls='ls -lha -G' 
alias grep='grep --color=auto'
alias listen="lsof -i -n | grep 'LISTEN'"

export EDITOR="nano"
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Unlimited History
export HISTFILESIZE=
export HISTSIZE=

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# cx_Oracle crap...
export ORACLE_HOME=/Users/bburn1/oracle
#export DYLD_LIBRARY_PATH=$ORACLE_HOME
#export LD_LIBRARY_PATH=$ORACLE_HOME

# Go puts it's stuff here...
export GOPATH=~/.gopath

##
# Your previous /Users/bburn1/.profile file was backed up as /Users/bburn1/.profile.macports-saved_2013-09-20_at_12:00:31
##

# MacPorts Installer addition on 2013-09-20_at_12:00:31: adding an appropriate PATH variable for use with MacPorts.
#export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Added for brewed ruby.
export PATH="/usr/local/opt/ruby/bin:$PATH"

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
