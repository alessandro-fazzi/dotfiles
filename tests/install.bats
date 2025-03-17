#!/usr/bin/env bats

setup() {
  # Create a temporary directory for testing
  export TEMP_HOME
  TEMP_HOME=$(mktemp -d)
  export HOME=$TEMP_HOME
  export BACKUP_DIR="$TEMP_HOME/backup"
}

teardown() {
  # Clean up the temporary directory
  rm -rf "$TEMP_HOME"
}

@test "backup_dir creates backup directory" {
  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  [ -d "$BACKUP_DIR" ]
}

@test "backup moves existing dotfiles to backup" {
  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  backup "$TEMP_HOME"  # Pass the temporary $HOME directory
  [ -f "$BACKUP_DIR/bashrc" ]
  [ -f "$BACKUP_DIR/bash_profile" ]
  [ -f "$BACKUP_DIR/curlrc" ]
  [ -f "$BACKUP_DIR/gemrc" ]
  [ -f "$BACKUP_DIR/gitconfig" ]
  [ -f "$BACKUP_DIR/gitignore" ]
  [ -f "$BACKUP_DIR/vimrc" ]
  [ -f "$BACKUP_DIR/config.fish" ]
}

@test "link creates symlinks to dotfiles" {
  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  backup
  link_dotfiles "$TEMP_HOME"  # Pass the temporary $HOME directory
  [ -L "$TEMP_HOME/.bashrc" ]
  [ -L "$TEMP_HOME/.bash_profile" ]
  [ -L "$TEMP_HOME/.curlrc" ]
  [ -L "$TEMP_HOME/.gemrc" ]
  [ -L "$TEMP_HOME/.gitconfig" ]
  [ -L "$TEMP_HOME/.gitignore" ]
  [ -L "$TEMP_HOME/.vimrc" ]
}

@test "warning is displayed for existing backup" {
  # Create some dummy dotfiles for testing
  touch "$TEMP_HOME"/.bashrc

  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  mkdir -p "$BACKUP_DIR"
  touch "$BACKUP_DIR"/bashrc

  # Capture the output
  run backup "$TEMP_HOME"  # Pass the temporary $HOME directory

  # Check if warning is in output
  [[ "$output" =~ "backup/bashrc already exists" ]]
}

@test "warning is displayed for existing symlink" {
  # Create some dummy dotfiles for testing
  touch "$TEMP_HOME"/.bashrc

  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  backup "$TEMP_HOME"  # Pass the temporary $HOME directory
  link_dotfiles "$TEMP_HOME"  # Pass the temporary $HOME directory

  # Capture the output
  run link_dotfiles "$TEMP_HOME"  # Pass the temporary $HOME directory

  # Check if warning is in output
  # shellcheck disable=SC2076
  [[ "$output" =~ ".bashrc already exists" ]]
}

@test "link_fish creates symlinks to fish config files" {
  # shellcheck disable=SC1091
  source ./install.sh
  backup_dir
  backup "$TEMP_HOME"  # Pass the temporary $HOME directory
  link_fish "$TEMP_HOME"  # Pass the temporary $HOME directory
  [ -L "$TEMP_HOME/.config/fish/config.fish" ]
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
