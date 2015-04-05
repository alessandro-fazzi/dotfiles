#!/bin/bash

BACKUP_DIR="$(pwd)/backup"
SUBLIME_FILES="$(pwd)/sublime/User"
SUBLIME_DEST_DIR="${HOME}/Library/Application Support/Sublime Text 3/Packages/User"

function backup_sublime() {
	[[ -d "$SUBLIME_DEST_DIR" && ! -L "$SUBLIME_DEST_DIR" ]] || return;
	backup="${BACKUP_DIR}/sublime/User"
	if [[ -d "$backup" ]]; then
		warn "$backup already exists"
	else
		cp -r "$SUBLIME_DEST_DIR" ${backup}
		rm -rf "$SUBLIME_DEST_DIR"
	fi
}

function link_sublime() {
	if [[ -d "$SUBLIME_DEST_DIR" ]]; then
		warn "${SUBLIME_DEST_DIR} already exists"
	else
		ln -s $SUBLIME_FILES "${SUBLIME_DEST_DIR}"
	fi

}

function sublime() {
	backup_sublime
	link_sublime
}


############################################

sublime

############################################
