#!/bin/bash

DOTFILES_DIR="."
BATS_DIR="${DOTFILES_DIR}/bats-core"
SHELLCHECK_DIR="${DOTFILES_DIR}/shellcheck"
SHELLCHECK_EXEC="${SHELLCHECK_DIR}/shellcheck"

function warn() {
  echo "$(tput bold)$(tput setaf 3)  *** ${1}$(tput sgr0)"
}

function install_bats() {
    if [[ ! -d $BATS_DIR ]]; then
        warn "Cloning bats-core into ${BATS_DIR}"
        git clone --depth 1 https://github.com/bats-core/bats-core.git $BATS_DIR
    else
        warn "bats-core is already installed in ${BATS_DIR}"
    fi
}

function install_shellcheck() {
    if [[ ! -d $SHELLCHECK_DIR || ! -f $SHELLCHECK_EXEC ]]; then
        warn "Installing shellcheck into ${SHELLCHECK_DIR}"
        mkdir -p $SHELLCHECK_DIR

        # Detect OS and architecture
        if [[ "$(uname)" == "Darwin" ]]; then
            if [[ "$(uname -m)" == "arm64" ]]; then
                warn "Detected macOS (aarch64)"
                curl -L https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.darwin.aarch64.tar.xz | tar -xJ -C $SHELLCHECK_DIR --strip-components=1
            else
                echo "Error: Unsupported architecture on macOS. Only aarch64 is supported."
                exit 1
            fi
        elif [[ "$(uname)" == "Linux" ]]; then
            warn "Detected Linux"
            curl -L https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz | tar -xJ -C $SHELLCHECK_DIR --strip-components=1
        else
            echo "Error: Unsupported operating system. Only macOS (aarch64) and Linux are supported."
            exit 1
        fi
    else
        warn "shellcheck is already installed in ${SHELLCHECK_DIR}"
    fi
}
