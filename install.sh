#!/usr/bin/env bash

DOTFILES_DIR="$(pwd)/files"
BACKUP_DIR="${BACKUP_DIR:-backup}"

# Source the configuration file that defines which files to manage
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/files.conf"

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
function link_files() {
    local base_dir=${1:-$HOME}  # Use the provided base directory or default to $HOME

    # Link all managed files
    for file_id in "${!MANAGED_FILES[@]}"; do
        local config="${MANAGED_FILES[$file_id]}"
        local source_file="${config%%:*}"
        local dest_path="${config##*:}"
        local source_path="${DOTFILES_DIR}/${source_file}"
        local target_path="${base_dir}/${dest_path}"

        # Create parent directory if it doesn't exist
        local parent_dir
        parent_dir=$(dirname "$target_path")
        mkdir -p "$parent_dir"

        # Link the file
        link "$source_path" "$target_path"
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

    # Backup all managed files
    for file_id in "${!MANAGED_FILES[@]}"; do
        local config="${MANAGED_FILES[$file_id]}"
        local source_file="${config%%:*}"
        local dest_path="${config##*:}"
        local target_file="${base_dir}/${dest_path}"

        # Skip if file doesn't exist or is already a symlink
        [[ -f $target_file && ! -L $target_file ]] || continue

        local backup_file="${BACKUP_DIR}/${source_file}"
        if [[ -f $backup_file ]]; then
            warn "${backup_file} already exists. Skipping."
            has_error=1
        else
            mv "$target_file" "$backup_file"
        fi
    done

    handle_error $has_error "Some files could not be backed up. Please check the warnings above."
    return $?
}

function backup_dir(){
    [[ -d $BACKUP_DIR ]] || mkdir -p "$BACKUP_DIR"
}

# Install a per-user launch agent for the repository's plist.
function install_launch_agents() {
    local launch_agents_dir="${PWD}/launch_agents"
    local user_launch_agents_dir="${HOME}/Library/LaunchAgents"
    local has_error=0

    # Gather all plist files in the repo launch_agents directory. Assume the repo folder exists.
    shopt -s nullglob
    local plists=("$launch_agents_dir"/*.plist)
    shopt -u nullglob

    # If no plists found, warn and skip
    if [[ ${#plists[@]} -eq 0 ]]; then
        warn "No launch agent plists found in ${launch_agents_dir}. Skipping launch agent installation."
        return 0
    fi

    # Ensure user's LaunchAgents directory exists
    mkdir -p "$user_launch_agents_dir"

    local launchctl_cmd="${LAUNCHCTL_CMD:-launchctl}"
    # Process each plist: symlink to ~/Library/LaunchAgents/ and load
    for src_plist in "${plists[@]}"; do
        local plist_name
        plist_name=$(basename "$src_plist")
        local target_plist="${user_launch_agents_dir}/${plist_name}"

        echo "Installing launch agent: $src_plist"
        if [[ "$(uname)" == "Darwin" || -n "$FORCE_MACOS" ]]; then
            # Unload from both possible locations
            "$launchctl_cmd" unload "$target_plist" 2>/dev/null || true
            "$launchctl_cmd" unload "$src_plist" 2>/dev/null || true

            # Create or update symlink
            if [[ -L "$target_plist" ]]; then
                rm "$target_plist"
            elif [[ -e "$target_plist" ]]; then
                warn "Regular file exists at ${target_plist}. Removing it to create symlink."
                rm "$target_plist"
            fi

            if ! ln -s "$src_plist" "$target_plist"; then
                warn "Failed to create symlink for ${plist_name}."
                has_error=1
                continue
            fi

            # Load from the symlinked location
            if ! "$launchctl_cmd" load "$target_plist"; then
                warn "Failed to load launch agent ${target_plist} with ${launchctl_cmd}."
                has_error=1
            else
                echo "Loaded launch agent: $target_plist"
            fi
        else
            warn "Not macOS (or FORCE_MACOS not set). Skipping launchctl load/unload for ${src_plist}."
        fi
    done

    handle_error $has_error "Some launch agents could not be installed/loaded."

    return 0
}

############################################

# Only run when script is executed, not when sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  backup_dir
  backup
  link_files
  install_launch_agents
fi

############################################
