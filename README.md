weLaika's dotfiles
===============================

## Installation:

1. Fork
2. Clone your fork into ".dotfiles":
   `git clone https://github.com/YOURNAME/dotfiles.git ~/.dotfiles`
3. Install:
   `cd ~/.dotfiles && bash install.sh`.
4. Update `[user]` section in `gitconfig` file
5. Edit to suit your needs

This will backup all the dotfiles that you are using in the `~/.dotfiles/backup`
directory and will install in your home symlinks to the dotfiles in the
`~/.dotfiles/files` folder.

## Features:

### General
* Automatically backs up existing dotfiles to `~/.dotfiles/backup`
* Symlinks dotfiles from `~/.dotfiles/files` to your home directory
* Includes setup and test scripts for validating shell scripts and configurations

### Supported Dotfiles
* `bash_profile`: Sources `.profile` and `.bashrc`
* `bashrc`:
  - Colored `ls` and `grep` by default
  - Destructive actions (`rm`, `mv`, `cp`, etc.) require confirmation
  - Autocorrects small typing mistakes in `cd` commands
  - Appends to `bash_history` instead of overwriting it
  - Increased bash history size to 10,000 lines
  - Includes useful shell options (`shopt`) for better usability
* `config.fish`:
  - Fish shell configuration with aliases, exports, and functions
  - Includes support for `rbenv`, `starship`, and `devbox`
* `curlrc`: Enables insecure mode for curl
* `gemrc`: Prevents documentation from being installed with gems
* `gitconfig`:
  - Includes useful aliases for common Git operations
  - Configures Git for better usability (e.g., auto-rebase, prune on fetch)
* `gitignore`: Excludes `devbox.json` and `devbox.lock`
* `starship.toml`: Configures the Starship prompt with custom symbols and disabled modules
* `vimrc`:
  - Syntax highlighting enabled
  - Git commit message-specific settings (spell check, text width)
  - Sane defaults for editing, searching, and window management

### Testing and Validation
* `setup_tests.sh`: Installs `bats-core` and `shellcheck` for testing and linting
* `test.sh`:
  - Runs `shellcheck` on all shell scripts in the project
  - Executes tests in the `tests` directory using `bats-core`
