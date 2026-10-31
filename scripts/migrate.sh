#!/bin/bash
# Run one-off migrations (migrations/<unix-timestamp>.sh) that have not run on
# this machine yet. State lives in $WS_STATE_DIR/migrations.
#   migrate.sh            run pending migrations
#   migrate.sh --mark-all record every migration as done without running it
#                         (fresh installs already have the end state)
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

DONE_DIR="$WS_STATE_DIR/migrations"
mkdir -p "$DONE_DIR"

shopt -s nullglob
for file in "$WS_DIR"/migrations/*.sh; do
  name="$(basename "$file")"
  [ -f "$DONE_DIR/$name" ] && continue

  if [ "${1:-}" = "--mark-all" ]; then
    touch "$DONE_DIR/$name"
    continue
  fi

  log "Running migration $name"
  bash "$file"
  touch "$DONE_DIR/$name"
done
