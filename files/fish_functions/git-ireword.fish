function git-ireword -d "Interactively pick a commit via fzf and reword it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l default (git symbolic-ref refs/remotes/$remote/HEAD | sed "s@^refs/remotes/$remote/@@")
    set -l selected (git log --oneline --no-decorate (git merge-base $default master)..HEAD | fzf)
    set -l commit (echo $selected | cut -d' ' -f1)

    if test -n "$commit"
        git history reword $commit
    end
end
