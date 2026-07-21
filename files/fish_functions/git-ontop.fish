function git-ontop -d "Update the parent branch (if it has a remote) and rebase the current branch on top of it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l parent (git-parent-branch $remote)
    set -l current (git symbolic-ref --short HEAD)

    if git rev-parse --abbrev-ref --symbolic-full-name "$parent@{upstream}" &>/dev/null
        echo (set_color green)"♻️ Updating $parent and rebasing $current on top of it..."(set_color normal)
        git switch "$parent" \
            && git pull "$remote" \
            && git switch "$current" \
            && git rebase "$parent"
    else
        echo (set_color green)"♻️ Rebasing $current on top of $parent (no upstream to pull)..."(set_color normal)
        git rebase "$parent"
    end
end
