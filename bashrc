## Prompt colors
red='\[\e[0;31m\]'
RED='\[\e[1;31m\]'
blue='\[\e[0;34m\]'
BLUE='\[\e[1;34m\]'
cyan='\[\e[0;36m\]'
CYAN='\[\e[1;36m\]'
black='\[\e[0;30m\]'
BLACK='\[\e[1;30m\]'
green='\[\e[0;32m\]'
GREEN='\[\e[1;32m\]'
yellow='\[\e[0;33m\]'
YELLOW='\[\e[1;33m\]'
magenta='\[\e[0;35m\]'
MAGENTA='\[\e[1;35m\]'
white='\[\e[0;37m\]'
WHITE='\[\e[1;37m\]'
NC='\[\e[0m\]'

function is_vim_running {
  jobs | grep -o 'vim' &> /dev/null
}

PROMPT_INFO="${BLUE}\w"
# PROMPT_RUBY="[\$( rvm-prompt u ' ' g )]"
# PROMPT_GIT="${YELLOW}\$(__git_ps1)"
PROMPT_GIT="\$(psgit_function)"
PROMPT_FOOTER="\n\$(is_vim_running && echo \"${RED}\" || echo \"${BLACK}\")↳ ${GREEN}\$ ${NC}"
BASH_STATUS='`if [[ $? == 0 ]]; then echo "\[\033[01;32m\]✔"; else echo "\[\033[01;31m\]✘"; fi`'
PROMPT_DIRTRIM=3

PS1="\n${BASH_STATUS} ${PROMPT_INFO} ${PROMPT_RUBY} ${PROMPT_GIT} ${PROMPT_FOOTER}"

## Aliases

alias l='ls -CF'
alias ls='ls -hFG'
alias ll='ls -hFlG'
alias la='ls -lhAFG'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='colordiff'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -hc'

alias recent='ls -lhAFt --color=auto'
alias ports='netstat -tulanp'
alias apache2_restart='sudo service apache2 restart'
alias mysql_restart='sudo service mysql restart'

alias hk='heroku'

# Expand aliases with sudo too
alias sudo='sudo '

# Security
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias chown='chown'
alias chmod='chmod'
alias chgrp='chgrp'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Bash aliases
source ~/.gitaliases

## Shopt options
shopt -s cdspell        # This will correct minor spelling errors in cd command.
shopt -s checkwinsize   # Check window size (rows, columns) after each command.
shopt -s cmdhist        # Save multi-line commands in history as single line.
shopt -s dotglob        # Include dotfile in path-name expansions.
shopt -s histappend     # Append to history rather than overwrite.
shopt -s nocaseglob     # Pathname expansion will be treated as case-insensitive.
shopt -s extglob        # Extended globbing expansion (see man bash -> Pathname Expansion - Pattern Matching)

## Bash completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

if [ -f /usr/local/etc/bash_completion.d/wp-completion.bash ]; then
  . /usr/local/etc/bash_completion.d/wp-completion.bash
fi

## Colored manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

## Exports
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL="ignoreboth"
export EDITOR="vim"

## Personal functions definition
[[ -s "$HOME/.bunctionsh" ]] && source "$HOME/.bunctionsh"

if [[ -f ~/.bunctionsh ]]; then
  source ~/.bunctionsh
fi


export PATH="/usr/local/mysql/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Fix some problems w/ iTerm2 and binding.pry
export LC_CTYPE=it_IT.UTF-8
export LANG=it_IT.UTF-8
export LC_ALL=it_IT.UTF-8

