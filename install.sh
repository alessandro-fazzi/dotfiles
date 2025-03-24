#!/bin/bash

DOTFILES_DIR="$(pwd)/files"
BACKUP_DIR="backup"
DOTFILES=(
bashrc
bash_profile
curlrc
gemrc
gitconfig
gitignore
vimrc
)
FISH_FILES=(
config.fish
)

function warn() {
  echo "$(tput bold)$(tput setaf 3)  *** ${1}$(tput sgr0)"
}

function link() {
    local source_file=$1
    local target_file=$2
    local has_error=0

    if [[ -e $target_file ]]; then
        if [[ -L $target_file ]]; then
            # It's a symlink - we'll overwrite it
            local previous_target
            previous_target=$(readlink "$target_file")
            warn "Symlink already exists at ${target_file} pointing to ${previous_target}. Overwriting."
            rm "$target_file"
            if ln -s "$source_file" "$target_file"; then
                echo "Created symlink: ${target_file} -> ${source_file}"
            fi
        else
            # It's a regular file - this shouldn't happen as backup should have moved it
            warn "${target_file} already exists as a regular file. The backup function should have moved it."
            warn "This is an unexpected situation. Please check your files and try again."
            has_error=1
            handle_error "$has_error" "Linking failed due to existing file. Backup may have failed."
            return $?
        fi
    else
        # No file exists - create the symlink
        if ln -s "$source_file" "$target_file"; then
            echo "Created symlink: ${target_file} -> ${source_file}"
        fi
    fi

    return 0
}

# shellcheck disable=SC2120
function link_dotfiles() {
    local base_dir=${1:-$HOME}  # Use the provided base directory or default to $HOME
    for script in "${DOTFILES[@]}"; do
        link "${DOTFILES_DIR}/$script" "${base_dir}/.${script}"
    done
}

# shellcheck disable=SC2120
function link_fish() {
    local base_dir=${1:-$HOME}  # Use the provided base directory or default to $HOME
    local fish_config_dir="${base_dir}/.config/fish"
    mkdir -p "$fish_config_dir"
    for fish_file in "${FISH_FILES[@]}"; do
        link "${DOTFILES_DIR}/$fish_file" "${fish_config_dir}/$fish_file"
    done
}

# Function to handle errors
function handle_error() {
    local has_error=$1
    local message=${2:-"Some files could not be processed. Please check the warnings above."}

    if [[ $has_error -eq 1 ]]; then
        warn "$message"
        # In the main script, we'll exit only if this is not being run in a test context
        if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
            exit 1
        else
            return 1
        fi
    fi

    return 0
}

# shellcheck disable=SC2120
function backup(){
    local base_dir=${1:-$HOME}  # Use the provided base directory or default to $HOME
    local has_error=0

    # Backup regular dotfiles
    for script in "${DOTFILES[@]}"; do
        dotfile=${base_dir}/.${script}
        # Skip if file doesn't exist or is already a symlink
        [[ -f $dotfile && ! -L $dotfile ]] || continue;
        backup=${BACKUP_DIR}/${script}
        if [[ -f $backup ]]; then
            warn "${BACKUP_DIR}/${script} already exists. Skipping."
            has_error=1
        else
            mv "$dotfile" "$backup"
        fi
    done

    # Backup fish config files
    local fish_config_dir="${base_dir}/.config/fish"
    for fish_file in "${FISH_FILES[@]}"; do
        local fish_path="${fish_config_dir}/${fish_file}"
        [[ -f $fish_path && ! -L $fish_path ]] || continue;
        local fish_backup="${BACKUP_DIR}/${fish_file}"
        if [[ -f $fish_backup ]]; then
            warn "${BACKUP_DIR}/${fish_file} already exists. Skipping."
            has_error=1
        else
            mv "$fish_path" "$fish_backup"
        fi
    done

    handle_error $has_error "Some files could not be backed up. Please check the warnings above."
}

function backup_dir(){
    [[ -d $BACKUP_DIR ]] || mkdir -p $BACKUP_DIR
}

############################################

# Only run when script is executed, not when sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  backup_dir
  backup
  link_dotfiles
  link_fish
fi

############################################
