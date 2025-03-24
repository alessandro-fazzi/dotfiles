#!/usr/bin/env bats

setup() {
  # Source install.sh to get access to the DOTFILES array
  # shellcheck disable=SC1091
  source ./install.sh

  # Create a temporary directory for testing
  export TEMP_HOME
  TEMP_HOME=$(mktemp -d)
  export HOME=$TEMP_HOME
  export BACKUP_DIR="$TEMP_HOME/backup"

  # Create a clean backup directory for each test
  rm -rf "$BACKUP_DIR" 2>/dev/null
  backup_dir
}

teardown() {
  # Clean up the temporary directory
  rm -rf "$TEMP_HOME"
}

@test "backup_dir creates backup directory" {
  backup_dir
  [ -d "$BACKUP_DIR" ]
}

@test "backup moves existing dotfiles to backup" {
  # Create the dotfiles in the temp home directory first
  for script in "${DOTFILES[@]}"; do
    touch "$TEMP_HOME/.$script"
  done

  # Create fish config file
  mkdir -p "$TEMP_HOME/.config/fish"
  for fish_file in "${FISH_FILES[@]}"; do
    touch "$TEMP_HOME/.config/fish/$fish_file"
  done

  backup "$TEMP_HOME"

  # Check if regular dotfiles were backed up
  for script in "${DOTFILES[@]}"; do
    [ -f "$BACKUP_DIR/$script" ]
  done

  # Check if fish config files were backed up
  for fish_file in "${FISH_FILES[@]}"; do
    [ -f "$BACKUP_DIR/$fish_file" ]
  done
}

@test "link creates symlinks to dotfiles" {
  backup "$TEMP_HOME"
  link_dotfiles "$TEMP_HOME"

  # Check if all dotfiles were linked
  for script in "${DOTFILES[@]}"; do
    [ -L "$TEMP_HOME/.$script" ]
  done
}

@test "warning is displayed for existing backup" {
  # Create some dummy dotfiles for testing
  touch "$TEMP_HOME"/.bashrc
  touch "$BACKUP_DIR"/bashrc

  # Capture the output
  run backup "$TEMP_HOME"  # Pass the temporary $HOME directory

  [ "$status" -eq 1 ]
  # Check if warning is in output
  [[ "$output" =~ "backup/bashrc already exists" ]]
}

@test "link_fish creates symlinks to fish config files" {
  backup_dir
  backup "$TEMP_HOME"  # Pass the temporary $HOME directory
  link_fish "$TEMP_HOME"  # Pass the temporary $HOME directory

  # Check if all fish config files were linked
  for fish_file in "${FISH_FILES[@]}"; do
    [ -L "$TEMP_HOME/.config/fish/$fish_file" ]
  done
}

@test "link creates symlinks for the given source and target" {
  # shellcheck disable=SC1091
  source ./install.sh

  # Create a dummy file for testing
  touch "$TEMP_HOME"/testfile

  # Capture the output
  run link "$TEMP_HOME"/testfile "$TEMP_HOME"/testlink

  # Check if symlink was created
  [ -L "$TEMP_HOME"/testlink ]
}

@test "link overwrites existing symlink" {
  # Create a target file that will be a symlink to an old location
  touch "$TEMP_HOME/old_target"

  # Create an initial symlink pointing to the old target
  ln -s "$TEMP_HOME/old_target" "$TEMP_HOME/existing_link"

  # Verify the initial symlink is set up correctly
  [ -L "$TEMP_HOME/existing_link" ]
  [ "$(readlink "$TEMP_HOME/existing_link")" = "$TEMP_HOME/old_target" ]

  # Create a new target file
  touch "$TEMP_HOME/new_target"

  # Run our link function to overwrite the symlink
  run link "$TEMP_HOME/new_target" "$TEMP_HOME/existing_link"

  # Check that the function's output contains our warning about overwriting
  [[ "$output" =~ "Symlink already exists" ]]
  [[ "$output" =~ "Overwriting" ]]

  # Verify the symlink now points to the new target
  [ -L "$TEMP_HOME/existing_link" ]
  [ "$(readlink "$TEMP_HOME/existing_link")" = "$TEMP_HOME/new_target" ]
}

@test "link returns error for existing regular files" {
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
  # Create a dummy error message
  local error_message="Test error occurred"

  # Capture the output
  run handle_error 1 "$error_message"

  # Check if the output contains the error message
  [[ "$output" =~ "$error_message" ]]
}
