function git-ifix -d "Interactively pick a commit via fzf and fixup staged changes into it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l parent (git-parent-branch $remote)
    if test $status -ne 0
        echo "🚫 No parent branch selected."
        return 1
    end
    set -l selected (git log --oneline --no-decorate $parent..HEAD | fzf)
    set -l parts (string split --max 1 ' ' $selected)
    set -l commit $parts[1]
    set -l message $parts[2]

    if test -n "$commit"
        printf "Fixing up currently staged changes into:\n\n"(set_color yellow)"$commit"(set_color normal)" $message\n\n"
        read -l -n 1 -P "Proceed? [Y/n] " reply
        if test -z "$reply" -o "$reply" = "y" -o "$reply" = "Y"
            git history fixup $commit
            if test $status -eq 0
                echo "✅"
            else
                echo "❌"
            end
        else
            echo "🚫"
        end
    end
end
