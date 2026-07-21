function git-prune-gone -d "Delete local branches that have no remote tracking branch"
    git fetch -p

    set -l local_branches (git branch -vv | grep ": gone]" | awk '{print $1}')

    if test -z "$local_branches"
        echo "No branches with gone remotes found."
        return 0
    end

    echo "Found branches with gone remotes:"

    for branch in $local_branches
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
