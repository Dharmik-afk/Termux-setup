# ================================
#   Termux Optimized Zsh Config
# ================================
# --- PATH Fix (Termux)
PROMPT="%F{cyan}%n%f %F{yellow}%~%f %# "
export PREFIX="/data/data/com.termux/files/usr"
export PATH="$PREFIX/bin:$PREFIX/bin/applets:$PATH"
export PKG="/data/data/com.termux/files/home/.local/share/zsh"
# --- Shell & Terminal
export SHELL="$PREFIX/bin/zsh"
export TERM="xterm-256color"
export EDITOR="nvim"
export CMAKE_PREFIX_PATH="$HOME/cpp_libs:$CMAKE_PREFIX_PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# --- Aliases
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'
alias up='pkg update && pkg upgrade -y'
alias v='nvim'

# --- History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Syntax Highlighting
source $PKG/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Autosuggestions
source $PKG/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Completion system
autoload -U compinit
compinit

# --- Prompt (Fast, simple)
PROMPT="%F{cyan}user%f %F{yellow}%~%f %# "

# --- Fix lazygit / fzf / ripgrep or other tools inside nvim
export FZF_DEFAULT_COMMAND='fd --type f'
# ================================
#      FZF + ZSH Integration
# ================================

# history search (Ctrl-R)
if [[ -f /data/data/com.termux/files/usr/share/fzf/key-bindings.zsh ]]; then
  source /data/data/com.termux/files/usr/share/fzf/key-bindings.zsh
fi

# completion support (Alt-C, Ctrl-T)
if [[ -f /data/data/com.termux/files/usr/share/fzf/completion.zsh ]]; then
  source /data/data/com.termux/files/usr/share/fzf/completion.zsh
fi

# Use fd for faster searching
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fzf_file() {
  local file
  file=$(fzf)
  [[ -n "$file" ]] && nvim "$file"
}
alias ff='fzf_file'

fdcd() {
  local dir
  dir=$(fd -t d | fzf) && cd "$dir"
}
alias fcd='fdcd'
