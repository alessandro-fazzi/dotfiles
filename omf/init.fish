# Bobthefish theme
set --global theme_nerd_fonts yes
set --global theme_color_scheme base16-dark
set --global theme_display_date no
set --global theme_newline_cursor yes
set --global theme_display_git yes
set --global theme_display_git_ahead_verbose yes
set --global theme_display_git_master_branch yes
set -g theme_display_git_stashed_verbose yes
set --global fish_prompt_pwd_dir_length 3
set --global theme_display_nvm yes

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

function code_socks5_proxy -d "Open a SOCKS5 proxy on the local 3128 port, passing connections to code.welaika.com"
  ssh -f -C -N -D 0.0.0.0:3128 code
end

function camar_socks5_proxy -d "Open a SOCKS5 proxy on the local 3128 port, passing connections to camar-redmine-production"
  ssh -f -C -N -D 0.0.0.0:3128 camar-redmine-production
end

function rails_s_debug -d "Fire a Rails server wrapped inside rdebug to attach an IDE to it"
  # Prerequisites:
  # gem install debase ruby-debug-ide
  # having the rails binstub
  rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- bin/rails server
end

alias hk 'heroku'

# Security
alias rm 'rm -i'
alias mv "mv -i"
alias cp 'cp -i'
alias ln 'ln -i'

## Exports
set --export --global HISTSIZE 10000
set --export --global HISTFILESIZE 10000
set --export --global HISTCONTROL "ignoreboth"
set --export --global EDITOR "vim"
set --export --global WORDPRESS_WORKS_PATH "$HOME/dev" # Wordmove automagic dev path

### Fix some problems w/ iTerm2 and binding.pry
set --export --global LC_CTYPE en_US.UTF-8
set --export --global LANG en_US.UTF-8
set --export --global LC_ALL en_US.UTF-8

# rbenv autoload
if command --search --quiet rbenv
  set --export --global RBENV_ROOT $HOME/.rbenv
  status --is-interactive; and . (rbenv init -|psub)
end

# Binstubs PATH
if not contains ./bin $PATH
  set PATH ./bin $PATH ^ /dev/null
end

#postgres.app executables
set PATH /Applications/Postgres.app/Contents/Versions/9.3/bin $PATH

### Composer BIN
set PATH $HOME/.composer/vendor/bin $PATH

### QT
set PATH (brew --prefix qt@5.5)/bin $PATH

### Elixir
set --export --global ERL_AFLAGS "-kernel shell_history enabled"
