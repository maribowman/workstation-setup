#!/bin/bash
# Install a systemd user timer that runs the restic backup daily.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$UNIT_DIR"

cat >"$UNIT_DIR/restic-backup.service" <<EOF
[Unit]
Description=Restic backup of \$HOME to NAS
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash $WS_DIR/scripts/restic_backup.sh
Nice=10
IOSchedulingClass=idle
EOF

cat >"$UNIT_DIR/restic-backup.timer" <<'EOF'
[Unit]
Description=Daily restic backup

[Timer]
OnCalendar=daily
RandomizedDelaySec=30m
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now restic-backup.timer
log "restic-backup.timer enabled (runs only once the repo is initialised: task backup-init)"
