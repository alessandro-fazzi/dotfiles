#!/usr/bin/env fish

# Uncomment the following line to print fish debug output during shell loading
#set -g fish_trace 1

# Activate homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by `rbenv init` on Mon Jan 13 22:30:21 CET 2025
status --is-interactive; and rbenv init - --no-rehash fish | source

# Load starship
starship init fish | source

# Aliases
alias l 'ls -CF'
alias ls 'ls -hFG'
alias ll 'ls -hFlG'
alias la 'ls -lhAFG'
alias mkdir 'mkdir -p'
alias df 'df -h'
alias du 'du -hc'
alias lr 'ls -lhAFt'
alias hk 'heroku'

## Security
alias rm 'rm -i'
alias mv "mv -i"
alias cp 'cp -i'
alias ln 'ln -i'

# Functions
function ports
  lsof -i -Pn | grep -i "listen"
end

function code_socks5_proxy -d "Open a SOCKS5 proxy on the local 3128 port, passing connections to code.welaika.com"
  ssh -f -C -N -D 0.0.0.0:3128 code
end

function camar_socks5_proxy -d "Open a SOCKS5 proxy on the local 3128 port, passing connections to camar-redmine-production"
  ssh -f -C -N -D 0.0.0.0:3128 camar-redmine-production
end

# Exports
set --export --global HISTSIZE 10000
set --export --global HISTFILESIZE 10000
set --export --global HISTCONTROL "ignoreboth"
set --export --global EDITOR "vim"
set --export --global WORDPRESS_WORKS_PATH "$HOME/dev" # Wordmove automagic dev path
set --export --global BUNDLER_EDITOR "code"

# postgres.app executables
fish_add_path --path /Applications/Postgres.app/Contents/Versions/latest/bin

# Devbox global
devbox global shellenv --init-hook | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.fish 2>/dev/null || :
