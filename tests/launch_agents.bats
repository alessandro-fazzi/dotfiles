#!/usr/bin/env bats

setup() {
  # Source install.sh to get access to functions
  # shellcheck disable=SC1091
  source ./install.sh

  TMPDIR=$(mktemp -d)
  export HOME="$TMPDIR"

  # Create a fake launchctl that logs its args
  LAUNCHCTL_LOG="$TMPDIR/launchctl.log"
  cat > "$TMPDIR/fake_launchctl" <<EOF
#!/bin/bash
echo "\$@" >> "$TMPDIR/launchctl.log"
EOF
  chmod +x "$TMPDIR/fake_launchctl"

  export LAUNCHCTL_CMD="$TMPDIR/fake_launchctl"
  export FORCE_MACOS=1
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "install_launch_agents invokes unload/load" {
  [ -f "$(pwd)/launch_agents/com.alessandro.brewupdatebundle.plist" ]

  run install_launch_agents "$HOME"

  # Check output for install and loaded messages
  expected_plist_path="$(pwd)/launch_agents/com.alessandro.brewupdatebundle.plist"
  [[ "$output" == *"Installing launch agent: $expected_plist_path"* ]]
  [[ "$output" == *"Loaded launch agent: $expected_plist_path"* ]]

  # Check fake launchctl log for exact commands
  grep -Fqx "unload $expected_plist_path" "$LAUNCHCTL_LOG"
  grep -Fqx "load $expected_plist_path" "$LAUNCHCTL_LOG"
}
