if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

if [ -f /usr/local/etc/bash_completion.d/wp-completion.bash ]; then
  . /usr/local/etc/bash_completion.d/wp-completion.bash
fi

source $HOME/.bashrc
export PATH=/usr/local/bin:$PATH
