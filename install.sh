#!/bin/bash

DOTFILES_DIR=".dotfiles"
BACKUP_DIR="backup"
DOTFILES=(
ackrc
bashrc
bash_profile
curlrc
gemrc
gitconfig
gitignore_global
inputrc
rvmrc
vimperatorrc
)

SUBLIME_FILES="$(pwd)/sublime/User"
SUBLIME_DEST_DIR="${HOME}/Library/Application Support/Sublime Text 3/Packages/User"

function warn() {
  echo "$(tput bold)$(tput setaf 3)  *** ${1}$(tput sgr0)"
}

function link(){
	for script in ${DOTFILES[@]}; do
		dotfile=${HOME}/.${script}
		if [[ -f $dotfile ]]; then
			warn "~/.${script} already exists"
		else
			ln -s ${DOTFILES_DIR}/$script $dotfile
		fi
	done
}

function backup(){
	for script in ${DOTFILES[@]}; do
		dotfile=${HOME}/.${script}
		[[ -f $dotfile && ! -L $dotfile ]] || continue;
		backup=${BACKUP_DIR}/${script}
		if [[ -f $backup ]]; then
			warn "${BACKUP_DIR}/${script} already exists"
		else
			mv $dotfile $backup
		fi
	done
}

function backup_sublime(){
	[[ -d "$SUBLIME_DEST_DIR" && ! -L "$SUBLIME_DEST_DIR" ]] || return;
	backup="${BACKUP_DIR}/sublime/User"
	if [[ -d "$backup" ]]; then
		warn "$backup already exists"
	else
		mv "$SUBLIME_DEST_DIR" ${backup}
	fi
}

function link_sublime(){
	if [[ -d "$SUBLIME_DEST_DIR" ]]; then
		warn "${SUBLIME_DEST_DIR} already exists"
	else
		ln -s $SUBLIME_FILES "${SUBLIME_DEST_DIR}"
	fi

}

function sublime(){
	backup_sublime
	link_sublime
}

function backup_dir(){
	[[ -d $BACKUP_DIR ]] || mkdir -p $BACKUP_DIR
}

############################################

backup_dir
backup
link
sublime

############################################
