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
    if [[ -f $target_file ]]; then
        warn "${target_file} already exists"
    else
        if ln -s "$source_file" "$target_file"; then
            echo "Created symlink: ${target_file} -> ${source_file}"
        fi
    fi
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

# shellcheck disable=SC2120
function backup(){
    local base_dir=${1:-$HOME}  # Use the provided base directory or default to $HOME
    for script in "${DOTFILES[@]}"; do
        dotfile=${base_dir}/.${script}
        [[ -f $dotfile && ! -L $dotfile ]] || continue;
        backup=${BACKUP_DIR}/${script}
        if [[ -f $backup ]]; then
            warn "${BACKUP_DIR}/${script} already exists. I'll stop here."
            exit 1
        else
            mv "$dotfile" "$backup"
        fi
    done
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
