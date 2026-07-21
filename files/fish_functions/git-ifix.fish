function git-ifix -d "Interactively pick a commit via fzf and fixup staged changes into it"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l default (git symbolic-ref refs/remotes/$remote/HEAD | sed "s@^refs/remotes/$remote/@@")
    set -l selected (git log --oneline --no-decorate (git merge-base $default master)..HEAD | fzf)
    set -l commit (echo $selected | cut -d' ' -f1)
    set -l message (echo $selected | cut -d' ' -f2-)

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
