function rbenv_prompt
  set_color 666
  echo -n "[ruby "(rbenv version | sed -e 's/ .*//')"]"
end

function fish_right_prompt
  rbenv_prompt
end

function is_vim_running
  jobs | grep -o 'vim' > /dev/null
end

## Aliases

alias l 'ls -CF'
alias ls 'ls -hFG'
alias ll 'ls -hFlG'
alias la 'ls -lhAFG'
alias mkdir 'mkdir -p'
alias df 'df -h'
alias du 'du -hc'
alias lr 'ls -lhAFt'

function ports
  lsof -i -Pn | grep -i "listen"
end

alias hk 'heroku'

# Security
alias rm 'rm -i'
alias mv "mv -i"
alias cp 'cp -i'
alias ln 'ln -i'
alias chown 'chown'
alias chmod 'chmod'
alias chgrp 'chgrp'

## Exports
set --export --global HISTSIZE 10000
set --export --global HISTFILESIZE 10000
set --export --global HISTCONTROL "ignoreboth"
set --export --global EDITOR "vim"
set --export --global WORDPRESS_WORKS_PATH "$HOME/dev" # Wordmove automagic dev path

### Added by the Heroku Toolbelt
set PATH /usr/local/heroku/bin $PATH

### Fix some problems w/ iTerm2 and binding.pry
set --export --global LC_CTYPE it_IT.UTF-8
set --export --global LANG it_IT.UTF-8
set --export --global LC_ALL it_IT.UTF-8

# Binstubs PATH
if not contains ./bin $PATH
  set PATH ./bin $PATH ^ /dev/null
end

#node_modules
if not contains ./node_modules/bin $PATH
  set PATH ./node_modules/bin $PATH
end

#Yarn
if not contains (yarn global bin) $PATH
  set PATH (yarn global bin) $PATH
end

#postgres.app executables
set PATH /Applications/Postgres.app/Contents/Versions/9.3/bin $PATH
