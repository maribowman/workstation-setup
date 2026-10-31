#!/bin/bash
# Restore secrets on a fresh machine:
#   1. Resilio Sync brings the KeePass vault into ~/Sync/credentials
#   2. one master-password prompt unlocks the vault
#   3. SSH keys and the restic password are exported from it
# Every step is skipped when its result already exists, so re-runs are silent.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

# ── Configuration (override via environment) ─────────────────────────────────
SYNC_DIR="${SYNC_DIR:-$HOME/Sync}"
KEEPASS_DIR="${KEEPASS_DIR:-$SYNC_DIR/credentials}"
KEEPASS_DB="${KEEPASS_DB:-}" # default: first *.kdbx in $KEEPASS_DIR

# Entry paths inside the vault and the attachment names on them.
GH_SSH_ENTRY="${GH_SSH_ENTRY:-GitHub SSH}"
GH_SSH_ATTACHMENT="${GH_SSH_ATTACHMENT:-id_ed25519}"
NAS_SSH_ENTRY="${NAS_SSH_ENTRY:-}" # empty: NAS uses the same key as GitHub
NAS_SSH_ATTACHMENT="${NAS_SSH_ATTACHMENT:-id_ed25519}"
RESTIC_ENTRY="${RESTIC_ENTRY:-Restic}"

GH_KEY="$HOME/.ssh/id_ed25519"
NAS_KEY="$HOME/.ssh/id_nas"
RESTIC_PASSWORD_FILE="$HOME/.config/restic/password"

# ── 1. Resilio Sync ──────────────────────────────────────────────────────────
resilio_unit() {
  # The AUR package has shipped the user unit under both names.
  local unit
  for unit in rslsync.service rslsync_user.service; do
    if systemctl --user cat "$unit" &>/dev/null; then
      echo "$unit"
      return
    fi
  done
  return 1
}

start_resilio() {
  local unit conf
  if ! unit="$(resilio_unit)"; then
    warn "No Resilio Sync user unit found (is rslsync installed?)"
    return 1
  fi

  # The user unit reads its config from ~/.config/rslsync; create a minimal one.
  conf="$HOME/.config/rslsync/rslsync.conf"
  if [ ! -f "$conf" ]; then
    mkdir -p "$(dirname "$conf")"
    cat >"$conf" <<EOF
{
  "storage_path": "$HOME/.config/rslsync",
  "pid_file": "$HOME/.config/rslsync/rslsync.pid",
  "webui": { "listen": "127.0.0.1:8888" }
}
EOF
  fi

  systemctl --user enable --now "$unit"
}

find_db() {
  if [ -n "$KEEPASS_DB" ]; then
    [ -f "$KEEPASS_DB" ] && echo "$KEEPASS_DB"
    return
  fi
  find "$KEEPASS_DIR" -maxdepth 1 -name '*.kdbx' 2>/dev/null | sort | head -n1
}

wait_for_vault() {
  local db
  db="$(find_db)"
  if [ -n "$db" ]; then
    echo "$db"
    return
  fi

  {
    log "KeePass vault not found in $KEEPASS_DIR"
    echo "    1. Open http://127.0.0.1:8888 and finish the Resilio setup"
    echo "    2. Add the 'credentials' folder (folder key from another device) to $KEEPASS_DIR"
    echo "    3. Leave this running — it continues as soon as the vault has synced"
  } >&2
  until db="$(find_db)" && [ -n "$db" ]; do
    sleep 10
  done
  # Give Resilio a moment to finish writing the file.
  sleep 5
  echo "$db"
}

# ── 2./3. Unlock and export ──────────────────────────────────────────────────
KP_PASSWORD=""

kp() { printf '%s\n' "$KP_PASSWORD" | keepassxc-cli "$1" -q "${@:2}"; }

unlock() {
  local db="$1" attempt
  for attempt in 1 2 3; do
    read -rsp "KeePass master password for $(basename "$db"): " KP_PASSWORD </dev/tty
    echo >&2
    if kp ls "$db" >/dev/null 2>&1; then
      return
    fi
    warn "Wrong password (attempt $attempt/3)"
  done
  return 1
}

export_ssh_key() {
  local db="$1" entry="$2" attachment="$3" dest="$4"
  [ -f "$dest" ] && return
  log "Exporting SSH key '$entry' -> $dest"
  kp attachment-export "$db" "$entry" "$attachment" "$dest"
  chmod 600 "$dest"
  ssh-keygen -y -f "$dest" >"$dest.pub"
}

main() {
  local db
  local need_gh=0 need_nas=0 need_restic=0
  [ -f "$GH_KEY" ] || need_gh=1
  [ -n "$NAS_SSH_ENTRY" ] && [ ! -f "$NAS_KEY" ] && need_nas=1
  [ -f "$RESTIC_PASSWORD_FILE" ] || need_restic=1

  start_resilio

  if ((need_gh + need_nas + need_restic == 0)); then
    log "Secrets already in place, skipping KeePass"
  else
    db="$(wait_for_vault)"
    unlock "$db"

    umask 077
    mkdir -p "$HOME/.ssh" "$(dirname "$RESTIC_PASSWORD_FILE")"
    chmod 700 "$HOME/.ssh"

    ((need_gh)) && export_ssh_key "$db" "$GH_SSH_ENTRY" "$GH_SSH_ATTACHMENT" "$GH_KEY"
    ((need_nas)) && export_ssh_key "$db" "$NAS_SSH_ENTRY" "$NAS_SSH_ATTACHMENT" "$NAS_KEY"
    if ((need_restic)); then
      log "Exporting restic password -> $RESTIC_PASSWORD_FILE"
      kp show -s -a password "$db" "$RESTIC_ENTRY" >"$RESTIC_PASSWORD_FILE"
    fi

    KP_PASSWORD=""
    unset KP_PASSWORD
  fi

  if ! grep -qs '^github.com ' "$HOME/.ssh/known_hosts"; then
    log "Adding github.com to known_hosts"
    ssh-keyscan -t ed25519 github.com 2>/dev/null >>"$HOME/.ssh/known_hosts"
  fi
}

main "$@"
