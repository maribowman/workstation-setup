#!/bin/bash
# Shared helpers, sourced by install.sh, scripts/* and the Taskfile.

# Repo root, regardless of which script sources this file.
WS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export WS_DIR

WS_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/workstation-setup"
export WS_STATE_DIR

log() { echo "==> $*"; }
warn() { echo "!!  $*" >&2; }

# Print the package names in a list file, one per line.
# Strips full-line and trailing comments and blank lines.
read_pkgs() {
  sed 's/#.*//; s/[[:space:]]*$//; s/^[[:space:]]*//' "$1" | grep -v '^$' || true
}
