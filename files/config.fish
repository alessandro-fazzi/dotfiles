#!/usr/bin/env fish

# Uncomment the following line to print fish debug output during shell loading
#set -g fish_trace 1

# Exports
set -gx LANG en_US.UTF-8
set -gx LC_COLLATE en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx LC_MESSAGES en_US.UTF-8
set -gx LC_MONETARY en_US.UTF-8
set -gx LC_NUMERIC en_US.UTF-8
set -gx LC_TIME en_US.UTF-8
set --export --global HISTSIZE 10000
set --export --global HISTFILESIZE 10000
set --export --global HISTCONTROL "ignoreboth"
set --export --global EDITOR "vim"
set --export --global WORDPRESS_WORKS_PATH "$HOME/dev" # Wordmove automagic dev path
set --export --global BUNDLER_EDITOR "code"
set --export --global XDG_CONFIG_HOME "$HOME/.config"

# Activate homebrew unless in Devbox shell. I'm testing this approach to
# avoid conflicts between Devbox and Homebrew installed packages.
if test -z $DEVBOX_SHELL_ENABLED
  eval "$(/opt/homebrew/bin/brew shellenv)"
end

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

function git-prune-gone -d "Delete local branches that have no remote tracking branch"
    git fetch -p

    set -l local_branches (git branch -vv | grep ": gone]" | awk '{print $1}')

    if test -z "$local_branches"
        echo "No branches with gone remotes found."
        return 0
    end

    echo "Found branches with gone remotes:"

    for branch in $local_branches
        # Simpler approach to extract remote info
        set -l remote_info (git for-each-ref --format='%(upstream:short)' refs/heads/$branch)

        echo -e "\nLocal branch: "(set_color cyan)"$branch"(set_color normal)
        echo "Remote was: "(set_color red)"$remote_info"(set_color normal)" (gone)"

        read -l -P "Delete this branch? (y/n/q) " choice
        switch $choice
            case y Y
                git branch -D "$branch"
                echo "Deleted branch $branch"
            case q Q
                echo "Exiting."
                return 0
            case '*'
                echo "Skipping branch $branch"
        end
    end
end

# postgres.app executables
fish_add_path --path /Applications/Postgres.app/Contents/Versions/latest/bin

# Devbox global
devbox global shellenv --init-hook | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.fish 2>/dev/null || :


alias claude="/Users/fuzzy/.claude/local/claude"

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/fuzzy/.lmstudio/bin
# End of LM Studio CLI section
