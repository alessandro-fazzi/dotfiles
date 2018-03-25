# Bobthefish theme
set --global theme_nerd_fonts yes
set --global theme_color_scheme base16-dark
set --global theme_display_date no
set --global theme_newline_cursor yes
set --global theme_display_git yes
set --global theme_display_git_ahead_verbose yes
set --global theme_display_git_master_branch yes

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

### Fix some problems w/ iTerm2 and binding.pry
set --export --global LC_CTYPE it_IT.UTF-8
set --export --global LANG it_IT.UTF-8
set --export --global LC_ALL it_IT.UTF-8

# rbenv autoload
if command --search --quiet rbenv
  set --export --global RBENV_ROOT $HOME/.rbenv
  status --is-interactive; and . (rbenv init -|psub)
end

# Binstubs PATH
if not contains ./bin $PATH
  set PATH ./bin $PATH ^ /dev/null
end

#node_modules
if not contains ./node_modules/bin $PATH
  set PATH ./node_modules/bin $PATH
end

#postgres.app executables
set PATH /Applications/Postgres.app/Contents/Versions/9.3/bin $PATH

### Homebrew PHP70 cli
set PATH (brew --prefix homebrew/php/php70)/bin $PATH
