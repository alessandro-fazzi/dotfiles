#!/usr/bin/env bats
# shellcheck disable=SC1091

setup() {
  # Create a temporary directory for testing
  export TEMP_HOME
  TEMP_HOME=$(mktemp -d)
  export HOME=$TEMP_HOME
  export BACKUP_DIR="$TEMP_HOME/backup"

  # Create a clean backup directory for each test
  rm -rf "$BACKUP_DIR" 2>/dev/null
}

teardown() {
  # Clean up the temporary directory
  rm -rf "$TEMP_HOME"
}

@test "backup_dir creates backup directory" {
  source ./install.sh
  backup_dir
  [ -d "$BACKUP_DIR" ]
}

@test "backup moves existing dotfiles to backup" {
  source ./install.sh

  backup_dir

  # Create all managed files in the temp home directory first
  for file_id in "${!MANAGED_FILES[@]}"; do
    local config="${MANAGED_FILES[$file_id]}"
    local source_file="${config%%:*}"
    local dest_path="${config##*:}"
    local target_file="${TEMP_HOME}/${dest_path}"

    # Create parent directory if needed
    mkdir -p "$(dirname "$target_file")"
    touch "$target_file"
  done

  backup "$TEMP_HOME"

  # Check if all files were backed up
  for file_id in "${!MANAGED_FILES[@]}"; do
    local config="${MANAGED_FILES[$file_id]}"
    local source_file="${config%%:*}"
    [ -f "$BACKUP_DIR/$source_file" ]
  done
}

@test "link creates symlinks to dotfiles" {
  source ./install.sh

  backup "$TEMP_HOME"
  link_files "$TEMP_HOME"

  # Check if all managed files were linked
  for file_id in "${!MANAGED_FILES[@]}"; do
    local config="${MANAGED_FILES[$file_id]}"
    local dest_path="${config##*:}"
    [ -L "$TEMP_HOME/${dest_path}" ]
  done
}

@test "warning is displayed for existing backup" {
  source ./install.sh

  # Create some dummy dotfiles for testing
  mkdir -p "$BACKUP_DIR"
  touch "$TEMP_HOME"/.bashrc
  touch "$BACKUP_DIR"/bashrc

  # Capture the output
  run backup "$TEMP_HOME"  # Pass the temporary $HOME directory

  [ "$status" -eq 1 ]
  # Check if warning is in output
  [[ "$output" =~ "bashrc already exists" ]]
}

@test "link_files creates symlinks to all config files including nested paths" {
  source ./install.sh

  backup_dir
  backup "$TEMP_HOME"  # Pass the temporary $HOME directory
  link_files "$TEMP_HOME"  # Pass the temporary $HOME directory

  # Check that nested config files (like .config/fish/config.fish) were linked
  [ -L "$TEMP_HOME/.config/fish/config.fish" ]
  [ -L "$TEMP_HOME/.config/starship.toml" ]
}

@test "link creates symlinks for the given source and target" {
  source ./install.sh

  # Create a dummy file for testing
  touch "$TEMP_HOME"/testfile

  # Capture the output
  run link "$TEMP_HOME"/testfile "$TEMP_HOME"/testlink

  # Check if symlink was created
  [ -L "$TEMP_HOME"/testlink ]
}

@test "link updates symlink when pointing to wrong target" {
  source ./install.sh

  # Create old and new target files
  touch "$TEMP_HOME/old_target"
  touch "$TEMP_HOME/new_target"

  # Create symlink pointing to old target
  ln -s "$TEMP_HOME/old_target" "$TEMP_HOME/test_link"

  # Verify initial setup
  [ -L "$TEMP_HOME/test_link" ]
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/old_target" ]

  # Run link function to update to new target
  run link "$TEMP_HOME/new_target" "$TEMP_HOME/test_link"

  # Should succeed
  [ "$status" -eq 0 ]

  # Should show updating messages
  [[ "$output" =~ "Updating" ]]
  [[ "$output" =~ "Symlink updated" ]]

  # Symlink should now point to new target
  [ -L "$TEMP_HOME/test_link" ]
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/new_target" ]
}

@test "link skips symlink when already pointing to correct target" {
  source ./install.sh

  # Create source and target files
  touch "$TEMP_HOME/source_file"

  # Create symlink pointing to correct target
  ln -s "$TEMP_HOME/source_file" "$TEMP_HOME/test_link"

  # Verify initial setup
  [ -L "$TEMP_HOME/test_link" ]
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/source_file" ]

  # Run link function
  run link "$TEMP_HOME/source_file" "$TEMP_HOME/test_link"

  # Should succeed
  [ "$status" -eq 0 ]

  # Should show skip message
  [[ "$output" =~ Already\ exists\.\ Skipping ]]

  # Should NOT show "Updating" or warning
  [[ ! "$output" =~ Updating ]]
  [[ ! "$output" =~ \*\*\* ]]

  # Symlink should still point to correct target
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/source_file" ]
}

@test "link shows correct message when creating new symlink" {
  source ./install.sh

  # Create source file
  touch "$TEMP_HOME/source_file"

  # Ensure target doesn't exist
  [ ! -e "$TEMP_HOME/test_link" ]

  # Run link function
  run link "$TEMP_HOME/source_file" "$TEMP_HOME/test_link"

  # Should succeed
  [ "$status" -eq 0 ]

  # Should show creation message
  [[ "$output" =~ "Creating symlink" ]]
  [[ "$output" =~ "Symlink created" ]]

  # Should NOT show skip or update messages
  [[ ! "$output" =~ "Skipping" ]]
  [[ ! "$output" =~ "Updating" ]]

  # Symlink should be created
  [ -L "$TEMP_HOME/test_link" ]
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/source_file" ]
}

@test "link updates broken symlink (pointing to non-existent target)" {
  source ./install.sh

  # Create new target file
  touch "$TEMP_HOME/new_target"

  # Create a broken symlink (pointing to non-existent file)
  ln -s "$TEMP_HOME/non_existent" "$TEMP_HOME/test_link"

  # Verify initial setup - symlink exists but target doesn't
  [ -L "$TEMP_HOME/test_link" ]
  [ ! -e "$TEMP_HOME/test_link" ]  # -e returns false for broken symlinks
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/non_existent" ]

  # Run link function to update to new target
  run link "$TEMP_HOME/new_target" "$TEMP_HOME/test_link"

  # Should succeed
  [ "$status" -eq 0 ]

  # Should show updating messages
  [[ "$output" =~ Updating ]]
  [[ "$output" =~ "Symlink updated" ]]

  # Symlink should now point to new target and not be broken
  [ -L "$TEMP_HOME/test_link" ]
  [ -e "$TEMP_HOME/test_link" ]  # Should now exist since target exists
  [ "$(readlink "$TEMP_HOME/test_link")" = "$TEMP_HOME/new_target" ]
}

@test "link returns error for existing regular files" {
  source ./install.sh

  # Create a regular file at the target location
  touch "$TEMP_HOME/regular_file"

  # Try to create a symlink at the location of an existing file
  touch "$TEMP_HOME/source_file"
  run link "$TEMP_HOME/source_file" "$TEMP_HOME/regular_file"

  # Check that the function returns an error status
  [ "$status" -eq 1 ]

  # Check that the output contains appropriate warning messages
  [[ "$output" =~ "already exists as a regular file" ]]
  [[ "$output" =~ "unexpected situation" ]]
}

@test "handle_error handles errors correctly" {
  source ./install.sh

  # Create a dummy error message
  local error_message="Test error occurred"

  # Capture the output
  run handle_error 1 "$error_message"

  # Check if the output contains the error message
  [[ "$output" =~ $error_message ]]
}
