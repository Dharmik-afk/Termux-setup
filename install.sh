#!/bin/bash

# --- 1. Setup Storage & Updates ---
echo "[*] Requesting storage access..."
termux-setup-storage
echo "[*] Updating Termux repositories..."
pkg update -y && pkg upgrade -y

# --- 2. Install Packages ---
echo "[*] Installing packages from list..."
if [ -f "pkglist.txt" ]; then
    # We read the list and install all packages at once
    xargs -a pkglist.txt pkg install -y
else
    echo "[!] Warning: pkglist.txt not found."
fi

# --- 3. Restore Configs (Symlinks) ---
create_link() {
    SRC="$1"
    DEST="$2"
    
    # Backup existing file if it's not already a symlink
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        mv "$DEST" "${DEST}.backup.$(date +%s)"
        echo "    Backed up existing $DEST"
    fi
    
    # Create the link
    ln -sf "$SRC" "$DEST"
    echo "    Linked $SRC -> $DEST"
}

echo "[*] Linking Dotfiles..."
create_link "$PWD/home/.zshrc" "$HOME/.zshrc"
create_link "$PWD/home/.gitconfig" "$HOME/.gitconfig"

echo "[*] Linking Neovim Config..."
mkdir -p "$HOME/.config"
# If ~/.config/nvim exists, we move it aside to ensure clean link
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
fi
ln -sf "$PWD/config/nvim" "$HOME/.config/nvim"

echo "[*] Linking Termux Properties..."
mkdir -p "$HOME/.termux"
create_link "$PWD/termux/termux.properties" "$HOME/.termux/termux.properties"
# Reload termux settings
termux-reload-settings

# --- 4. Final Setup ---
echo "[*] Setting Zsh as default shell..."
chsh -s zsh

rm -rf ~/.termux 
cp -r termux ~/ 
mv termux ~/.termux

mkdir ~/.local/share/zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.local/share/zsh/
git clone https://github.com/zsh-users/zsh-autosuggestions.git  ~/local/share/zsh

source ~/.zshrc
echo "----------------------------------------"
echo "RESTORE COMPLETE!"
echo "1. Restart Termux."
echo "2. Open Neovim - LazyVim will auto-install plugins."
echo "----------------------------------------"
