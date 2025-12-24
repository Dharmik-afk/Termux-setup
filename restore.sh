#!/data/data/com.termux/files/usr/bin/bash
# Termux Restore Script

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

log() { printf "[*] %s\n" "$1"; }
warn() { printf "[!] %s\n" "$1" >&2; }
die() {
  printf "[✗] %s\n" "$1" >&2
  exit 1
}

# --------------------------------------------------
# Symlink Helper
# --------------------------------------------------
create_link() {
  local SRC="$1"
  local DEST="$2"

  [[ -e "$SRC" ]] || die "Source missing: $SRC"

  if [[ -e "$DEST" && ! -L "$DEST" ]]; then
    local BACKUP="${DEST}.backup.$(date +%s)"
    mv "$DEST" "$BACKUP"
    log "Backed up $DEST -> $BACKUP"
  fi

  ln -sfn "$SRC" "$DEST"
  log "Linked $DEST -> $SRC"
}

# --------------------------------------------------
# 1. Dotfiles
# --------------------------------------------------
log "Linking dotfiles..."

create_link "$SCRIPT_DIR/home/.zshrc" "$HOME_DIR/.zshrc"
create_link "$SCRIPT_DIR/home/.gitconfig" "$HOME_DIR/.gitconfig"

# --------------------------------------------------
# 2. Neovim Config
# --------------------------------------------------
log "Linking Neovim config..."

NVIM_SRC="$SCRIPT_DIR/config/nvim"
NVIM_DEST="$HOME_DIR/.config/nvim"

[[ -d "$NVIM_SRC" ]] || die "Missing Neovim config: $NVIM_SRC"

mkdir -p "$HOME_DIR/.config"

if [[ -e "$NVIM_DEST" && ! -L "$NVIM_DEST" ]]; then
  mv "$NVIM_DEST" "${NVIM_DEST}.backup.$(date +%s)"
  log "Backed up existing Neovim config"
fi

ln -sfn "$NVIM_SRC" "$NVIM_DEST"

# --------------------------------------------------
# 3. Termux Config
# --------------------------------------------------
log "Linking Termux config..."

TERMUX_SRC="$SCRIPT_DIR/termux"
TERMUX_DEST="$HOME_DIR/.termux"

[[ -d "$TERMUX_SRC" ]] || die "Missing termux config"

create_link "$TERMUX_SRC" "$TERMUX_DEST"

termux-reload-settings || warn "Failed to reload Termux settings"

# --------------------------------------------------
# 4. Zsh Plugins
# --------------------------------------------------
log "Installing Zsh plugins..."

ZSH_PLUGIN_DIR="$HOME_DIR/.local/share/zsh"
mkdir -p "$ZSH_PLUGIN_DIR"

install_plugin() {
  local NAME="$1"
  local REPO="$2"
  local DEST="$ZSH_PLUGIN_DIR/$NAME"

  if [[ -d "$DEST/.git" ]]; then
    log "Updating $NAME..."
    git -C "$DEST" pull --ff-only
  else
    log "Cloning $NAME..."
    git clone "$REPO" "$DEST"
  fi
}

install_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git"

install_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git"

# --------------------------------------------------
# Completion
# --------------------------------------------------
log "----------------------------------------"
log "RESTORE COMPLETE"
log "Restart Termux, then open Neovim"
log "----------------------------------------"
