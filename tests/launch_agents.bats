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

  run install_launch_agents

  # Check output for install and loaded messages
  expected_src_plist="$(pwd)/launch_agents/com.alessandro.brewupdatebundle.plist"
  expected_target_plist="$HOME/Library/LaunchAgents/com.alessandro.brewupdatebundle.plist"

  [[ "$output" == *"Installing launch agent: $expected_src_plist"* ]]
  [[ "$output" == *"Loaded launch agent: $expected_target_plist"* ]]

  # Check that symlink was created
  [ -L "$expected_target_plist" ]
  [ "$(readlink "$expected_target_plist")" = "$expected_src_plist" ]

  # Check fake launchctl log for exact commands (should unload both locations, then load from target)
  grep -Fqx "unload $expected_target_plist" "$LAUNCHCTL_LOG"
  grep -Fqx "unload $expected_src_plist" "$LAUNCHCTL_LOG"
  grep -Fqx "load $expected_target_plist" "$LAUNCHCTL_LOG"
}
