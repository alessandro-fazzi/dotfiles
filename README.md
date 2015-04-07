weLaika's dotfiles
===============================

## Installation:

Prerequisites: ruby, rvm

1. Fork
2. Clone your fork into ".dotfiles":
   `git clone https://github.com/YOURNAME/dotfiles.git ~/.dotfiles`
3. Install:
  `cd ~/.dotfiles && bash install.sh`. Supply `--sublime` flag in order
  to install sublime files
4. Update `[user]` section in `gitconfig` file
5. Edit to suit your needs

This will backup all the dotfiles that you are using in the `~/.dotfiles/backup`
directory and will install in your home symlinks to the dotfiles in the
`~/dotfiles` folder.

## Features:

* ackrc recognizes sass, scss, erb, haml, slim, coffee, yml, (...) files
* bash\_profile loads bashrc
* bashrc contains some sane defaults:
  - ls and grep are colored by default
  - destructive actions require confirmation
  - autocorrects small typing mistakes
  - automatically includes dotfiles using the `*` operator
  - append to bash\_history instead of overwriting it
  - bash history size is increased to 10'000 lines
  - commands starting with space and duplicate commands are removed from bashrc
  - man pages are colored
  - rvm compatible
* gemrc prevents documentation from being installed
* gitconfig contains some useful aliases
* inputrc allows some fun tricks:
  - bash file completion is case insensitive
  - the list of possible completions is triggered by a single `tab` hit
  - symbolic link to directories have `/` automatically appended by completion
  - history search of commands: type ls, press `↑` and browse through commands
    starting with ls :)
* rvmrc disables rvms noisy messages and whiny confermation questions
* sublime text packages and configuration. Sublime must be previously installed
  and the package control plugin [already installed](https://packagecontrol.io/installation).
  At the moment will be installed the following packages:

      ├── Bats.sublime-settings
      ├── Bats.tmLanguage
      ├── Default\ (Linux).sublime-keymap
      ├── Default\ (OSX).sublime-keymap
      ├── GitGutter.sublime-settings
      ├── Glue.sublime-settings
      ├── JavaScript\ (Rails).sublime-settings
      ├── Makefile.sublime-settings
      ├── MarkdownPreview.sublime-settings
      ├── Monokai.tmTheme
      ├── PHP\ Haml.sublime-settings
      ├── PHP.sublime-settings
      ├── Package\ Control.ca-bundle
      ├── Package\ Control.ca-list
      ├── Package\ Control.merged-ca-bundle
      ├── Package\ Control.sublime-settings
      ├── Package\ Control.system-ca-bundle
      ├── Package\ Control.user-ca-bundle
      ├── Preferences.sublime-settings
      ├── Ruby\ Haml.sublime-settings
      ├── Ruby\ Slim.sublime-settings
      ├── Ruby.sublime-settings
      ├── RubyTest.last-run
      ├── RubyTest.sublime-settings
      ├── Sass.sublime-settings
      ├── Shell-Unix-Generic.sublime-settings
      ├── SublimeLinter
      │   └── Monokai\ (SL).tmTheme
      ├── SublimeLinter.sublime-settings
      ├── SublimeREPL.sublime-settings
      ├── Terminal.sublime-settings
      └── YAML.sublime-settings
