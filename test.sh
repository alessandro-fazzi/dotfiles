#!/bin/bash

BATS_EXEC="./bats-core/bin/bats"
SETUP_SCRIPT="./setup_tests.sh"
TEST_DIR="./tests"
SHELLCHECK_EXEC="./shellcheck/shellcheck"

# Dynamically find all shell scripts in the project root directory and all .bats files in tests/
SHELL_SCRIPTS=$(find . -maxdepth 1 -type f \( -name "*.sh" -o -name "*.bash" \); find ./tests -type f -name "*.bats")

# Check for CI environment
if [[ -n "$CI" ]]; then
  # In CI, install dependencies automatically without prompting
  if [[ ! -x $BATS_EXEC ]]; then
    # shellcheck disable=SC1090
    source $SETUP_SCRIPT
    install_bats
  fi

  if [[ ! -x $SHELLCHECK_EXEC ]]; then
    # shellcheck disable=SC1090
    source $SETUP_SCRIPT
    install_shellcheck
  fi
else
  # Regular interactive checks for local development
  if [[ ! -x $BATS_EXEC ]]; then
    echo "Error: bats-core is not installed or executable not found at $BATS_EXEC"
    read -r -p "Would you like to install bats-core? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
      if [[ -f $SETUP_SCRIPT ]]; then
        # shellcheck disable=SC1090
        source $SETUP_SCRIPT
        install_bats
      else
        echo "Error: Setup script not found at $SETUP_SCRIPT"
        exit 1
      fi
    else
      echo "bats-core is required to run the tests. Exiting."
      exit 1
    fi
  fi

  if [[ ! -x $SHELLCHECK_EXEC ]]; then
    echo "Error: shellcheck is not installed or executable not found at $SHELLCHECK_EXEC"
    read -r -p "Would you like to install shellcheck? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
      if [[ -f $SETUP_SCRIPT ]]; then
        # shellcheck disable=SC1090
        source $SETUP_SCRIPT
        install_shellcheck
      else
        echo "Error: Setup script not found at $SETUP_SCRIPT"
        exit 1
      fi
    else
      echo "shellcheck is required to lint the scripts. Exiting."
      exit 1
    fi
  fi
fi

echo "Running shellcheck on shell scripts..."
for script in $SHELL_SCRIPTS; do
  if [[ -f $script ]]; then
    if ! $SHELLCHECK_EXEC "$script"; then
      echo "Shellcheck failed for $script. Please fix the issues and try again."
      exit 1
    fi
  else
    echo "Warning: $script not found, skipping."
  fi
done

echo "Shellcheck passed for all scripts."

$BATS_EXEC $TEST_DIR
