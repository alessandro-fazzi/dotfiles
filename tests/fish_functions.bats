#!/usr/bin/env bats

setup() {
  export REPO_ROOT
  REPO_ROOT="$(pwd)"
  export FISH_FN_DIR="$REPO_ROOT/files/fish_functions"

  export TEMP_REPO
  TEMP_REPO=$(mktemp -d)
  cd "$TEMP_REPO" || exit 1

  git init -q -b master
  git config user.email "test@test.com"
  git config user.name "Test"
}

teardown() {
  cd "$REPO_ROOT" || exit 1
  rm -rf "$TEMP_REPO"
}

run_git_parent_branch() {
  fish -c "source '$FISH_FN_DIR/git-parent-branch.fish'; git-parent-branch"
}

@test "git-parent-branch finds the immediate parent in a stacked branch chain" {
  echo a > f
  git add f
  git commit -qm "master commit"
  git checkout -q -b branch_1
  echo b >> f
  git add f
  git commit -qm "branch_1 commit"
  git checkout -q -b branch_2
  echo c >> f
  git add f
  git commit -qm "branch_2 commit"

  run run_git_parent_branch

  [ "$status" -eq 0 ]
  [ "$output" = "branch_1" ]
}

@test "git-parent-branch ignores a default branch that has advanced past the fork point" {
  echo a > f
  git add f
  git commit -qm "master commit"
  git checkout -q -b branch_1
  echo b >> f
  git add f
  git commit -qm "branch_1 commit"
  git checkout -q -b branch_2
  echo c >> f
  git add f
  git commit -qm "branch_2 commit"

  git checkout -q master
  echo d >> f2
  git add f2
  git commit -qm "master advanced (simulated pull)"
  git checkout -q branch_2

  run run_git_parent_branch

  [ "$status" -eq 0 ]
  [ "$output" = "branch_1" ]
}

@test "git-parent-branch falls back to the remote default branch when no local branch shares history" {
  echo a > f
  git add f
  git commit -qm "initial commit"

  mkdir -p "$TEMP_REPO/remote.git"
  git init -q --bare "$TEMP_REPO/remote.git"
  git remote add origin "$TEMP_REPO/remote.git"
  git push -q -u origin master
  git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/master

  git checkout -q --orphan feature
  git commit -q --allow-empty -m "unrelated history"

  run run_git_parent_branch

  [ "$status" -eq 0 ]
  [ "$output" = "master" ]
}

@test "git-parent-branch prompts on a tie and returns the branch the user picks" {
  echo a > f
  git add f
  git commit -qm "root commit"
  git checkout -q -b branch_a
  echo b >> f
  git add f
  git commit -qm "branch_a commit"
  git checkout -q master
  git checkout -q -b feature
  echo c >> f2
  git add f2
  git commit -qm "feature commit"

  run run_git_parent_branch <<< "2"

  [ "$status" -eq 0 ]
  [ "$(echo "$output" | tail -1)" = "master" ]
}

@test "git-parent-branch aborts cleanly when the tie prompt is left empty" {
  echo a > f
  git add f
  git commit -qm "root commit"
  git checkout -q -b branch_a
  echo b >> f
  git add f
  git commit -qm "branch_a commit"
  git checkout -q master
  git checkout -q -b feature
  echo c >> f2
  git add f2
  git commit -qm "feature commit"

  run run_git_parent_branch <<< ""

  [ "$status" -eq 1 ]
}
