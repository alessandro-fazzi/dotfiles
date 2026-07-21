function git-parent-branch -d "Find the branch HEAD was forked from: the nearest local branch it descends from, or the remote default branch as fallback"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l current (git symbolic-ref --short HEAD)
    set -l candidates

    for branch in (git for-each-ref --format='%(refname:short)' refs/heads/)
        test "$branch" = "$current"; and continue
        git merge-base --is-ancestor $branch HEAD 2>/dev/null; and set -a candidates $branch
    end

    for candidate in $candidates
        set -l is_closest 1
        for other in $candidates
            test "$other" = "$candidate"; and continue
            git merge-base --is-ancestor $other $candidate 2>/dev/null; or set is_closest 0
        end
        if test $is_closest -eq 1
            echo $candidate
            return
        end
    end

    # No local branch found in HEAD's ancestry — fall back to the remote default branch
    git symbolic-ref refs/remotes/$remote/HEAD | sed "s@^refs/remotes/$remote/@@"
end
