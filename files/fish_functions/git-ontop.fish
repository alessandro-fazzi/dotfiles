function git-ontop -d "Update the default branch and rebase the current branch on top of it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l default (git symbolic-ref refs/remotes/$remote/HEAD | sed "s@^refs/remotes/$remote/@@")
    set -l current (git symbolic-ref --short HEAD)

    echo (set_color green)"♻️ Updating $default and rebasing $current on top of it..."(set_color normal)

    git switch "$default" \
        && git pull "$remote" \
        && git switch "$current" \
        && git rebase "$default"
end
