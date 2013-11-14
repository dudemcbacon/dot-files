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

#
# Nike Specific Stuff
#

# Nike Proxy

# Export necessary environment variables to run correctly

. /cust/tools/bin/b2c.sh

if [ `hostname` == 'nike.vagrant' ]; then
  export PATH=$PATH:/vagrant/scripts
  PS1='\[\033[01;33m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	function ep { nano /vagrant/.profile; source ~/.profile; }
else
  export PATH=/cust/soe/opt/python/2.7.3/bin/:/usr/local/bin:$PATH:~/vagrant/nike-vagrant/scripts:~/brandon
  PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	function ep { nano ~/vagrant/.profile; source ~/.profile; }
	export http_proxy=http://72.37.244.131:8080
	export https_proxy=http://72.37.244.131:8080
fi

# Java Related stuff, Maven, Ant, etc
#export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
#export PATH=/usr/local/apache-maven/apache-maven-3.0.4/bin:$PATH
#export M2_HOME=/usr/local/apache-maven/apache-maven-3.0.4
#export M2=$M2_HOME/bin
#export PATH=/usr/local/apache-ant/apache-ant-1.8.2/bin:$PATH
#export ANT_HOME=/usr/local/apache-ant/apache-ant-1.8.2

# useful functions/aliases
function vcstags { mvn com.nike.mojo:nike-deploy-maven-plugin:list-vcstags -Dnike-deploy.module=$1; }
export -f vcstags

function deploymod { mvn com.nike.mojo:nike-deploy-maven-plugin:1.0.1-SNAPSHOT:deploy -Dnike-deploy.env=$1 -Dnike-deploy.user=bburn1 -Dnike-deploy.password=Sgollerskates1 -Dnike-deploy.modules=$2; }
export -f deploymod

export -f ep 

# Undeploy an app from an enivornment.
function undeploy { rdeploy -undeploy --env $1 --app $2 --user bburn1; }
export -f undeploy

function deployr { http_proxy="" rdeploy --env $1 --app $2 --version 2 --user bburn1; }
export -f deployr



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
