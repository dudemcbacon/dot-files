# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
alias zshconfig="subl ~/.zshrc"

# Look in .oh-my-zsh/plugins for more.
plugins=(brew colored-man git osx, python, tmux, virtualenv)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/cust/soe/opt/python/2.7.3/bin/:/usr/local/bin:/cust/soe/usr/bin:/bin:/cust/tools/bin:/usr/bin:/sbin:/usr/sbin:/lc/bin:/lc/sbin:/usr/local/bin:/usr/local/nike/bin:/Users/bburn1/vagrant/nike-vagrant/scripts:/Users/bburn1/brandon:/Applications/apache-jmeter-2.10/bin

# Source my old dot-files.
source ~/.profile