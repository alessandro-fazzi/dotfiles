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

## Configuration

The files managed by this dotfiles repository are configured in `files.conf`. This configuration file uses a bash associative array to map files from the `files/` directory to their destination in your home directory.

### Adding a New Managed File

To add a new file to be managed by the dotfiles installer:

1. **Place your file** in the `~/.dotfiles/files/` directory
2. **Edit `files.conf`** and add an entry to the `MANAGED_FILES` array:
   ```bash
   [unique_id]="source_file:destination_path"
   ```
   - `unique_id`: A unique identifier for this file (e.g., `tmux`, `zshrc`)
   - `source_file`: The filename in the `files/` directory
   - `destination_path`: The path relative to `$HOME` where it should be linked

3. **Run the installer**: `./install.sh`

### Examples

```bash
# Links files/bashrc to $HOME/.bashrc
[bashrc]="bashrc:.bashrc"

# Links files/config.fish to $HOME/.config/fish/config.fish
[fish_config]="config.fish:.config/fish/config.fish"

# Links files/starship.toml to $HOME/.config/starship.toml
[starship]="starship.toml:.config/starship.toml"
```

The installer will automatically:
- Create any necessary parent directories (e.g., `.config/fish/`)
- Back up existing files before creating symlinks
- Link all configured files in a single pass

## Launch Agents

* Any `.plist` files placed in `~/.dotfiles/launch_agents/` will be automatically (re)loaded using `launchctl` during install.
* The installer will attempt to `launchctl unload` and then `launchctl load` each plist in that folder (macOS only).
* This allows you to manage custom user launch agents (e.g., scheduled jobs, background services) as part of your dotfiles setup.
* The install script assumes the folder exists and will skip with a warning if no plists are present.
* See `tests/launch_agents.bats` for automated test coverage of this feature.

## Features:

### General
* Automatically backs up existing files to `~/.dotfiles/backup`
* Symlinks dotfiles from `~/.dotfiles/files` to their destination
* Tested

### Supported Dotfiles
* `bash_profile`: Sources `.profile` and `.bashrc` to ensure all settings are properly loaded
* `bashrc`:
  - Colored `ls` and `grep` by default for better readability
  - Destructive actions (`rm`, `mv`, `cp`, etc.) require confirmation with `-i` flag
  - Autocorrects small typing mistakes in `cd` commands with `cdspell`
  - Appends to `bash_history` instead of overwriting it with `histappend`
  - Increased bash history size to 10,000 lines with `HISTSIZE` and `HISTFILESIZE`
  - Includes useful shell options (`shopt`) like `autocd`, `checkwinsize` for better usability
  - Provides useful aliases for common commands
* `config.fish`:
  - Sets locale environment variables for proper UTF-8 support
  - Activates Homebrew automatically using `/opt/homebrew/bin/brew shellenv`
  - Initializes `rbenv` for Ruby version management without rehashing
  - Configures `starship` prompt for customized terminal appearance
  - Includes useful aliases for common commands:
    - File listing with various options (`l`, `ls`, `ll`, `la`, `lr`)
    - Safety flags for destructive commands (`rm -i`, `mv -i`, `cp -i`, `ln -i`)
    - Improved versions of `mkdir`, `df`, `du`
    - Shorthand for Heroku CLI (`hk`)
  - Provides helpful functions:
    - `ports` to list all listening ports
    - `code_socks5_proxy` and `camar_socks5_proxy` for SSH tunneling
    - `git-prune-gone` to manage stale Git branches
  - Sets environment variables:
    - Increased history size (10,000 lines)
    - Sets vim as default editor
    - Configures paths for WordPress development and Bundler
  - Adds PostgreSQL from Postgres.app to PATH
  - Loads Devbox global environment
  - Integrates with OrbStack for container/VM management
* `curlrc`:
  - Enables insecure mode for curl with `--insecure` option
  - Configures default behavior for curl commands
* `gemrc`:
  - Prevents documentation from being installed with gems to save space and time
  - Optimizes gem installation settings
* `gitconfig`:
  - User configuration with name, email, and SSH signing key setup
  - Core settings:
    - Handles line endings intelligently with `autocrlf = input` and `safecrlf = true`
    - Uses global gitignore file (`excludesfile = ~/.gitignore`)
  - Diff improvements:
    - Uses histogram algorithm for better diffs
    - Shows submodule changes in log format
    - Enables color-moved detection and mnemonic prefixes
  - Pull/Push configurations:
    - Sets `pull.rebase = true` to avoid merge commits
    - Configures `push.default = simple` with `autoSetupRemote` and `followTags`
  - Fetch optimization with pruning of obsolete references
  - Rebase enhancements:
    - Enables `autoSquash`, `autoStash`, and `updateRefs` for smoother rebasing
  - Sets `main` as the default branch for new repositories
  - Uses SSH for GPG signing format
  - Branch and tag sorting for better organization
  - Enables helpful auto-correction for Git commands
  - Enables ReReRe (Reuse Recorded Resolution) for consistent conflict resolution
  - Rich set of useful aliases:
    - File tracking management (`assume`, `unassume`)
    - Shortcuts for common commands (`c`, `cm`, `st`, `ap`, `all`)
    - Force pushing safely with `pf` (using `--force-with-lease`)
    - Various log formats (`lcur`, `l`, `ls`) with decorations and graph visualization
    - Commit amending helpers (`reco`, `recore`)
    - Integration with external diff tools (`difft` for difftastic)
    - Stale branch management with `gone` alias
  - Custom color settings for status output
* `gitignore`:
  - Global gitignore rules for development tools and environment files
  - Excludes `devbox.json` and `devbox.lock` from Git repositories
  - Ignores common temporary and system files
* `vimrc`:
  - Syntax highlighting enabled for better code readability
  - Git commit message-specific settings (spell check, text width)
  - Sane defaults for editing, searching, and window management
  - Custom key mappings for improved productivity
  - Tab and indentation settings for consistent code formatting
  - Line numbering and visual indicators for code structure
* `starship.toml`:
  - Custom terminal prompt configuration
  - Managed and symlinked to `~/.config/starship.toml`
  - Used by the fish shell (referenced in `config.fish`)


### Automatic Brewfile

* The Brewfile in `~/.dotfiles/Brewfile` is automatically generated and updated by a launch agent.
* This agent runs `brew bundle dump --file=$HOME/.dotfiles/Brewfile --describe --force` daily, keeping your Homebrew package list in sync.
* You can use this Brewfile to quickly set up or restore your development environment on a new machine.

### TODO

- devbox global

### Testing and Validation
* `setup_tests.sh`: Installs (locally into the project folder) `bats-core` and
  `shellcheck` for testing and linting
* `test.sh`:
  - Runs `shellcheck` on all shell scripts in the project
  - Executes tests in the `tests` directory using `bats-core`
