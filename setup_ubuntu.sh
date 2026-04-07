#!/bin/bash
# Premium terminal setup for Ubuntu 24.04
# Run: chmod +x setup_ubuntu.sh && ./setup_ubuntu.sh

set -e

echo ""
echo "── Updating packages ───────────────────────────────────"
sudo apt update -qq

echo ""
echo "── 1/8  Zsh ────────────────────────────────────────────"
if ! command -v zsh &>/dev/null; then
  sudo apt install -y zsh
  sudo chsh -s "$(which zsh)" "$USER"
  echo "✓ Zsh installed — will be default shell after logout/login"
else
  echo "✓ Already installed"
fi

echo ""
echo "── 2/8  Git + curl + build tools ──────────────────────"
sudo apt install -y git curl wget unzip fontconfig
echo "✓ Done"

echo ""
echo "── 3/8  Starship (prompt) ──────────────────────────────"
if command -v starship &>/dev/null; then
  echo "✓ Already installed ($(starship --version 2>&1 | head -1))"
else
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  echo "✓ Starship installed"
fi

echo ""
echo "── 4/8  eza (modern ls) ────────────────────────────────"
if command -v eza &>/dev/null; then
  echo "✓ Already installed"
else
  sudo apt install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  if wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg; then
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update -qq
    sudo apt install -y eza
    echo "✓ eza installed"
  else
    echo "⚠ eza: GPG key download failed, skipping"
  fi
fi

echo ""
echo "── 5/8  bat (modern cat) ───────────────────────────────"
sudo apt install -y bat
# Ubuntu installs it as 'batcat' to avoid conflict
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
echo "✓ bat installed (symlinked as 'bat')"

echo ""
echo "── 6/8  fzf (fuzzy finder) ─────────────────────────────"
if [ -d ~/.fzf ]; then
  # Ensure zsh integration is generated for git-clone install
  ~/.fzf/install --all --no-bash --no-fish --no-update-rc 2>/dev/null || true
  echo "✓ Already installed (via git clone) — zsh keybindings generated"
else
  sudo apt install -y fzf
  echo "✓ fzf installed — ctrl+r: history search, ctrl+t: file search"
fi

echo ""
echo "── 7/8  zsh plugins ────────────────────────────────────"
sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting
echo "✓ Plugins installed"

echo ""
echo "── 8/8  tree + broot ───────────────────────────────────"
sudo apt install -y tree
echo "✓ tree installed"
# broot — skip if a valid ELF binary is already installed
BROOT_BIN=$(command -v broot 2>/dev/null || true)
if [ -n "$BROOT_BIN" ] && file "$BROOT_BIN" 2>/dev/null | grep -q 'ELF.*executable'; then
  echo "✓ broot already installed ($BROOT_BIN)"
else
  # Remove corrupt/non-ELF leftover if present (e.g. a failed download wrote HTML)
  [ -n "$BROOT_BIN" ] && sudo rm -f "$BROOT_BIN"
  # Derive latest version from the redirect URL — avoids GitHub API rate limits
  BROOT_VERSION=$(curl -sIL -o /dev/null -w '%{url_effective}' \
    https://github.com/Canop/broot/releases/latest \
    | grep -oP 'v[\d.]+$')
  if [ -n "$BROOT_VERSION" ]; then
    # Detect architecture
    BROOT_ARCH=$(uname -m)
    case "$BROOT_ARCH" in
      x86_64)  BROOT_TARGET="x86_64-unknown-linux-musl" ;;
      aarch64) BROOT_TARGET="aarch64-unknown-linux-gnu" ;;
      *)       BROOT_TARGET="" ;;
    esac
    if [ -z "$BROOT_TARGET" ]; then
      echo "⚠ broot: unsupported architecture $BROOT_ARCH, skipping (run: cargo install broot)"
    else
      # Zip filename uses version without the leading 'v' (e.g. v1.56.2 → broot_1.56.2.zip)
      BROOT_VER="${BROOT_VERSION#v}"
      BROOT_URL="https://github.com/Canop/broot/releases/download/${BROOT_VERSION}/broot_${BROOT_VER}.zip"
      echo "  Downloading broot ${BROOT_VERSION} (${BROOT_ARCH})..."
      curl -sL "$BROOT_URL" -o /tmp/broot.zip
      unzip -qo /tmp/broot.zip "${BROOT_TARGET}/broot" -d /tmp/broot_extracted
      if file "/tmp/broot_extracted/${BROOT_TARGET}/broot" | grep -q 'ELF.*executable'; then
        chmod +x "/tmp/broot_extracted/${BROOT_TARGET}/broot"
        sudo mv "/tmp/broot_extracted/${BROOT_TARGET}/broot" /usr/local/bin/broot
        rm -rf /tmp/broot.zip /tmp/broot_extracted
        # --install creates the launcher script (~/.config/broot/launcher/bash/br)
        # but also patches .zshrc/.bashrc directly with hardcoded absolute paths.
        # We undo that: setup.zsh already sources the launcher with $HOME.
        broot --install || true
        sed -i '/broot\/launcher/d' "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" 2>/dev/null || true
        echo "✓ broot ${BROOT_VERSION} installed"
      else
        rm -rf /tmp/broot.zip /tmp/broot_extracted
        echo "⚠ broot: extracted file is not a valid binary"
        echo "  Install manually: cargo install broot"
      fi
    fi
  else
    echo "⚠ broot: could not determine latest version, skipping (run: cargo install broot)"
  fi
fi

echo ""
echo "── Nerd Font (JetBrainsMono) ───────────────────────────"
if fc-list | grep -qi "JetBrainsMono.*Nerd"; then
  echo "✓ Already installed"
else
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o /tmp/JetBrainsMono.zip
  unzip -qo /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
  fc-cache -f
  echo "✓ JetBrainsMono Nerd Font installed"
fi

echo ""
echo "── Writing shell config ────────────────────────────────"
# Strategy: write our config to a dedicated file (~/.config/zsh/setup.zsh)
# and only add a single source line to ~/.zshrc.
# This way tools like conda/nvm/rustup that rewrite ~/.zshrc won't destroy
# our configuration — they only append their own blocks, leaving the source
# line intact.
SETUP_ZSH="$HOME/.config/zsh/setup.zsh"
mkdir -p "$HOME/.config/zsh"

cat > "$SETUP_ZSH" << 'EOF'
# ─────────────────────────────────────────────────────────────
#  PATH
# ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# ─────────────────────────────────────────────────────────────
#  HISTORY
# ─────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY EXTENDED_HISTORY

# ─────────────────────────────────────────────────────────────
#  COMPLETION
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
setopt AUTO_CD CORRECT

# ─────────────────────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────────────────────
export CLICOLOR=1
alias grep='grep --color=auto'

# ─────────────────────────────────────────────────────────────
#  KEY BINDINGS
# ─────────────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ─────────────────────────────────────────────────────────────
#  ALIASES — navigation
# ─────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias -- -='cd -'
alias reload='source ~/.zshrc && echo "  zshrc reloaded"'
alias path='echo $PATH | tr ":" "\n"'

# ─────────────────────────────────────────────────────────────
#  ALIASES — git
# ─────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --color'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# ─────────────────────────────────────────────────────────────
#  eza — modern ls
# ─────────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons --level=2'

# ─────────────────────────────────────────────────────────────
#  bat — modern cat
# ─────────────────────────────────────────────────────────────
alias cat='bat --paging=never'
export BAT_THEME="TwoDark"

# ─────────────────────────────────────────────────────────────
#  tree
# ─────────────────────────────────────────────────────────────
alias tree='tree -C'
alias t2='tree -L 2'
alias t3='tree -L 3'
alias td='tree -d'

# ─────────────────────────────────────────────────────────────
#  FUNCTIONS
# ─────────────────────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }
f() { find . -iname "*$1*" 2>/dev/null; }
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;; *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;; *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1"  ;; *.tar)      tar xf "$1"  ;;
    *.zip)     unzip "$1"   ;; *.7z)       7z x "$1"    ;;
    *) echo "Unknown archive: $1" ;;
  esac
}

# ─────────────────────────────────────────────────────────────
#  fzf — fuzzy finder (ctrl+r: history, ctrl+t: files)
# ─────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=dark"

# ─────────────────────────────────────────────────────────────
#  broot — interactive tree navigator (type 'br')
# ─────────────────────────────────────────────────────────────
[[ -f ~/.config/broot/launcher/bash/br ]] && \
  source ~/.config/broot/launcher/bash/br

# ─────────────────────────────────────────────────────────────
#  zsh-autosuggestions — ghost-text from history (→ to accept)
# ─────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ─────────────────────────────────────────────────────────────
#  zsh-syntax-highlighting — must be sourced LAST among plugins
# ─────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────
#  ROS 2 Jazzy
# ─────────────────────────────────────────────────────────────
[ -f /opt/ros/jazzy/setup.zsh ] && source /opt/ros/jazzy/setup.zsh

# export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
# export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
# export ROS_DOMAIN_ID=1
# export CYCLONEDDS_URI=/home/fanyang1/cyclonedds_ros2.xml

# ─────────────────────────────────────────────────────────────
#  Starship prompt (must be last)
# ─────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
EOF
echo "✓ Shell config written to $SETUP_ZSH"

# Add source line to ~/.zshrc only if not already present (idempotent)
SOURCE_LINE="[ -f \"\$HOME/.config/zsh/setup.zsh\" ] && source \"\$HOME/.config/zsh/setup.zsh\""
if ! grep -qF '.config/zsh/setup.zsh' "$HOME/.zshrc" 2>/dev/null; then
  # Prepend the source line so it loads before conda/nvm/etc blocks
  tmp=$(mktemp)
  echo "$SOURCE_LINE" | cat - "$HOME/.zshrc" 2>/dev/null > "$tmp" && mv "$tmp" "$HOME/.zshrc" || echo "$SOURCE_LINE" > "$HOME/.zshrc"
  echo "✓ Added source line to ~/.zshrc"
else
  echo "✓ ~/.zshrc already sources setup.zsh — no changes needed"
fi

echo ""
echo "── Copying Starship config ─────────────────────────────"
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP_EOF'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[╭─](bold 240) $directory$git_branch$git_status$python$nodejs$rust $time
[╰─❯](bold green) """

right_format = "$cmd_duration$status"

[directory]
style = "bold cyan"
truncation_length = 4
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bold magenta"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold red"
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
modified = "!${count}"
untracked = "?${count}"
staged = "+${count}"
deleted = "✘${count}"

[time]
disabled = false
format = "[$time]($style)"
style = "bold 240"
time_format = "%H:%M"

[cmd_duration]
min_time = 2_000
format = "[ $duration](bold yellow)"

[status]
disabled = false
format = "[$symbol$status]($style) "
symbol = "✘ "
style = "bold red"
not_executable_symbol = "🔒 "
not_found_symbol = "🔍 "

[python]
symbol = " "
style = "bold yellow"
format = '[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style) '

[nodejs]
symbol = " "
style = "bold green"
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
style = "bold red"
format = "[$symbol($version)]($style) "
STARSHIP_EOF
echo "✓ Starship config written"

echo ""
echo "── Conda (init for zsh) ──────────────────────────────────"
# Detect conda prefix: anaconda3 or miniconda3 (or custom CONDA_PREFIX)
CONDA_PREFIX_DIR=""
for candidate in "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/miniforge3" "$HOME/mambaforge"; do
  if [ -d "$candidate" ]; then
    CONDA_PREFIX_DIR="$candidate"
    break
  fi
done

if [ -n "$CONDA_PREFIX_DIR" ]; then
  if grep -q 'conda initialize' "$SETUP_ZSH" 2>/dev/null; then
    echo "✓ Conda already configured in setup.zsh"
  else
  # Write conda init into our dedicated config file (not ~/.zshrc)
  # so it survives if conda re-runs init later and rewrites ~/.zshrc.
  cat >> "$SETUP_ZSH" << CONDA_EOF

# ─────────────────────────────────────────────────────────────
#  Conda ($CONDA_PREFIX_DIR)
# ─────────────────────────────────────────────────────────────
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('$CONDA_PREFIX_DIR/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "$CONDA_PREFIX_DIR/etc/profile.d/conda.sh" ]; then
        . "$CONDA_PREFIX_DIR/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_PREFIX_DIR/bin:\$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
CONDA_EOF
  echo "✓ Conda initialized for zsh (using $CONDA_PREFIX_DIR)"
  fi
else
  echo "⚠ No conda installation found (anaconda3/miniconda3/miniforge3), skipping"
fi

echo ""
echo "─────────────────────────────────────────────────────────"
echo "  Done!"
echo ""
echo "  Next steps:"
echo "  1. Log out and back in (or run: zsh) to use Zsh"
echo "  2. Set terminal font to: JetBrainsMono Nerd Font"
echo "  3. Run: source ~/.zshrc"
echo ""
echo "  Config file: ~/.config/zsh/setup.zsh"
echo "  (Edit that file to customize — it survives conda/nvm rewrites)"
echo "─────────────────────────────────────────────────────────"
