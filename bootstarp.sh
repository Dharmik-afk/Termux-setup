#!/data/data/com.termux/files/usr/bin/bash
# Termux Bootstrap Script

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "[*] %s\n" "$1"; }
warn() { printf "[!] %s\n" "$1" >&2; }
die() {
  printf "[✗] %s\n" "$1" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

# --------------------------------------------------
# Preconditions
# --------------------------------------------------
require pkg
require git

# --------------------------------------------------
# 1. Storage Access
# --------------------------------------------------
log "Requesting storage access..."
termux-setup-storage || warn "Storage already configured or denied."

# --------------------------------------------------
# 2. Update System
# --------------------------------------------------
log "Updating Termux repositories..."
pkg update -y
pkg upgrade -y

# --------------------------------------------------
# 3. Install Packages
# --------------------------------------------------
PKGLIST="$SCRIPT_DIR/pkglist.txt"

if [[ -f "$PKGLIST" ]]; then
  log "Installing packages from pkglist.txt..."
  grep -Ev '^\s*#|^\s*$' "$PKGLIST" | xargs pkg install -y
else
  warn "pkglist.txt not found, skipping package install."
fi

# --------------------------------------------------
# 4. Zsh Setup
# --------------------------------------------------
log "Configuring Zsh..."

require zsh
chsh -s "$(command -v zsh)"

ZSH_GLOBAL_RC="/data/data/com.termux/files/usr/etc/zshrc"

if [[ -f "$ZSH_GLOBAL_RC" ]]; then
  if ! grep -q 'source ~/.zshrc' "$ZSH_GLOBAL_RC"; then
    echo '' >>"$ZSH_GLOBAL_RC"
    echo '# Load user zshrc if present' >>"$ZSH_GLOBAL_RC"
    echo '[[ -f ~/.zshrc ]] && source ~/.zshrc' >>"$ZSH_GLOBAL_RC"
    log "Updated global zshrc"
  else
    log "Global zshrc already configured"
  fi
else
  warn "Global zshrc not found"
fi

log "Bootstrap completed successfully"
