if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
source $HOME/.bashrc
export PATH=/usr/local/bin:$PATH
