function git-isplit -d "Interactively pick a commit via fzf and split it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l parent (git-parent-branch $remote)
    set -l selected (git log --oneline --no-decorate $parent..HEAD | fzf)
    set -l commit (string split --max 1 ' ' $selected)[1]

    if test -n "$commit"
        git history split $commit
    end
end
