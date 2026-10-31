#!/bin/bash
# Show the difference between explicitly installed packages and the declared lists.
# Base-system packages from the CachyOS installer can be silenced by listing them
# in packages/drift-ignore.txt.
set -eEo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../install/lib.sh"

P="$WS_DIR/packages"
declared="$( (read_pkgs "$P/pacman.txt"; read_pkgs "$P/aur.txt") | sort -u)"
ignored="$( ([ -f "$P/drift-ignore.txt" ] && read_pkgs "$P/drift-ignore.txt") | sort -u)"
installed="$(pacman -Qqe | sort -u)"

echo "==> Installed explicitly but not declared:"
comm -23 <(echo "$installed") <(echo "$declared") | comm -23 - <(echo "$ignored") | sed 's/^/    /'

echo "==> Declared but not installed:"
comm -13 <(echo "$installed") <(echo "$declared") | sed 's/^/    /'

if command -v flatpak &>/dev/null; then
  echo "==> Flatpak apps installed but not declared:"
  comm -23 <(flatpak list --app --columns=application | sort -u) <(read_pkgs "$P/flatpak.txt" | sort -u) | sed 's/^/    /'
fi
