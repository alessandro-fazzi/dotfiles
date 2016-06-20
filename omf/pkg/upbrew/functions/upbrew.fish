# SYNOPSIS
#   upbrew [options]
#
# USAGE
#   Options
#

function init -a path --on-event init_upbrew
  if not type -q brew
    echo "Please install 'brew' first!"; return 1
  end
end

function upbrew -d "Upgrade brew and brew-cask packages and clean 'open with' menu"
  brew update
  brew upgrade

  for app in (brew cask list)
    brew cask install $app
  end

  brew cleanup
  brew cask cleanup
  upbrew_delete_old_brew_casks

  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user
  killall Finder
  echo "Open With menu has been rebuilt, Finder will relaunch"
end

function upbrew_delete_old_brew_casks -d "Delete older-than-the-last-installed-version casks versions"
  if not test "Darwin" = (uname)
    return 1
  end

  if not test -d /opt/homebrew-cask/Caskroom
    return 1
  end

  cd /opt/homebrew-cask/Caskroom

  for cask in (ls | tr -d '/')
    for old_cask in (ls -t -1 $cask | tail -n +2 | tr -d '/')
      echo "Deleting old cask $cask version $old_cask"
      rm -rf "$cask/$old_cask"
    end
  end

  prevd
end

function uninstall --on-event uninstall_upbrew

end
