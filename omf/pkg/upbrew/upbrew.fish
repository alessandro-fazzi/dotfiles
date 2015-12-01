# SYNOPSIS
#   upbrew [options]
#
# USAGE
#   Options
#

function init -a path --on-event init_upbrew
  if not available brew
    echo "Please install 'brew' first!"; return 1
  end
end

function upbrew -d "Upgrade brew and brew-cask packages and clean 'open with' menu"
  brew update
  brew upgrade

  for app in (brew cask list)
    brew cask install --force $app
  end

  brew cleanup
  brew-cask cleanup

  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user
  killall Finder
  echo "Open With menu has been rebuilt, Finder will relaunch"
end

function uninstall --on-event uninstall_upbrew

end
