function git-parent-branch -d "Find the branch HEAD was forked from: the local branch with the most recent merge-base with HEAD, asking interactively on a tie, or the remote default branch as fallback"
    set -l remote origin
    if set -q argv[1]
        set remote $argv[1]
    end

    set -l current (git symbolic-ref --short HEAD)
    set -l best_count -1
    set -l tied

    for branch in (git for-each-ref --format='%(refname:short)' refs/heads/)
        test "$branch" = "$current"; and continue

        set -l base (git merge-base $branch HEAD 2>/dev/null)
        test -z "$base"; and continue

        set -l count (git rev-list --count $base..HEAD)
        if test $best_count -eq -1 -o $count -lt $best_count
            set best_count $count
            set tied $branch
        else if test $count -eq $best_count
            set -a tied $branch
        end
    end

    if test (count $tied) -eq 1
        echo $tied[1]
        return 0
    end

    if test (count $tied) -gt 1
        echo (set_color yellow)"Multiple branches are equally close to HEAD:"(set_color normal) >&2
        for i in (seq (count $tied))
            echo "  $i) $tied[$i]" >&2
        end
        read -l -P "Pick one [1-"(count $tied)"], or press Enter to abort: " choice

        if string match -qr '^[0-9]+$' -- "$choice"
            if test "$choice" -ge 1 -a "$choice" -le (count $tied)
                echo $tied[$choice]
                return 0
            end
        end

        return 1
    end

    # No local branch shares any history with HEAD — fall back to the remote default branch
    set -l default (git symbolic-ref refs/remotes/$remote/HEAD 2>/dev/null | sed "s@^refs/remotes/$remote/@@")
    if test -n "$default"
        echo $default
        return 0
    end

    return 1
end
