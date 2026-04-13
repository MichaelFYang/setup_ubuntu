#!/bin/zsh
# Premium macOS dev environment setup
# Run: chmod +x setup_macos.sh && ./setup_macos.sh

set -e

echo ""
echo "── 1/10  Homebrew ───────────────────────────────────────"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "✓ Homebrew installed"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "✓ Already installed"
fi

echo ""
echo "── 2/10  Starship (prompt) ──────────────────────────────"
if command -v starship &>/dev/null; then
  echo "✓ Already installed ($(starship --version 2>&1 | head -1))"
else
  brew install starship
  echo "✓ Starship installed"
fi

echo ""
echo "── 3/10  fzf (fuzzy finder) ─────────────────────────────"
if command -v fzf &>/dev/null; then
  echo "✓ Already installed"
else
  brew install fzf
  echo "✓ fzf installed"
fi
# Ensure zsh keybindings are generated (safe to re-run)
FZF_INSTALL="$(brew --prefix)/opt/fzf/install"
[ -x "$FZF_INSTALL" ] && "$FZF_INSTALL" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
echo "  ctrl+r: history search, ctrl+t: file search"

echo ""
echo "── 4/10  eza (modern ls) ────────────────────────────────"
if command -v eza &>/dev/null; then
  echo "✓ Already installed"
else
  brew install eza
  echo "✓ eza installed"
fi

echo ""
echo "── 5/10  bat (modern cat) ───────────────────────────────"
if command -v bat &>/dev/null; then
  echo "✓ Already installed"
else
  brew install bat
  echo "✓ bat installed"
fi

echo ""
echo "── 6/10  zsh-syntax-highlighting ────────────────────────"
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  echo "✓ Already installed"
else
  brew install zsh-syntax-highlighting
  echo "✓ Commands turn green when valid, red when not found"
fi

echo ""
echo "── 7/10  zsh-autosuggestions ────────────────────────────"
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  echo "✓ Already installed"
else
  brew install zsh-autosuggestions
  echo "✓ Ghost-text history suggestions — press → to accept"
fi

echo ""
echo "── 8/10  delta (git diff viewer) ────────────────────────"
if command -v delta &>/dev/null; then
  echo "✓ Already installed"
else
  brew install git-delta
  echo "✓ delta installed"
fi
# Configure delta only if not already set (preserve user's existing pager)
if [ "$(git config --global core.pager)" != "delta" ]; then
  git config --global core.pager delta
  git config --global delta.navigate true
  git config --global delta.side-by-side true
  git config --global delta.line-numbers true
  git config --global delta.syntax-theme TwoDark
  echo "  delta configured as git pager"
else
  echo "  delta already configured as git pager"
fi

echo ""
echo "── 9/10  tree (static file tree) ────────────────────────"
if command -v tree &>/dev/null; then
  echo "✓ Already installed"
else
  brew install tree
  echo "✓ tree installed"
fi

echo ""
echo "── 10/10  broot (interactive tree) ──────────────────────"
if command -v broot &>/dev/null; then
  echo "✓ Already installed"
else
  brew install broot
  echo "✓ broot installed"
fi
broot --install || true
# Remove broot's hardcoded .zshrc patches — our setup.zsh already sources the launcher
sed -i '' '/broot\/launcher/d' "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" 2>/dev/null || true
echo "  Type 'br' to launch"

echo ""
echo "── Nerd Font (JetBrainsMono) ────────────────────────────"
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
  echo "✓ Already installed"
else
  brew install --cask font-jetbrains-mono-nerd-font
  echo "✓ JetBrainsMono Nerd Font installed"
fi
echo "  Set it in: VSCode → Terminal Font Family, or Terminal.app → Preferences → Font"

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
#  Homebrew (Apple Silicon) — must be early for PATH
# ─────────────────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

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
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
setopt AUTO_CD CORRECT

# ─────────────────────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
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
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias reload='source ~/.zshrc && echo "  zshrc reloaded"'
alias path='echo $PATH | tr ":" "\n"'
alias myip='curl -s ifconfig.me && echo'

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
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ─────────────────────────────────────────────────────────────
#  zsh-syntax-highlighting — must be sourced LAST among plugins
# ─────────────────────────────────────────────────────────────
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────
#  Starship prompt
# ─────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
EOF
echo "✓ Shell config written to $SETUP_ZSH"

# Back up existing .zshrc if present (only on first run — don't overwrite previous backup)
if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.bak ]; then
  cp ~/.zshrc ~/.zshrc.bak
  echo "  (backed up existing .zshrc to .zshrc.bak)"
fi

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
echo "── Writing Starship config ──────────────────────────────"
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP_EOF'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[╭─](bold 240) $directory$git_branch$git_status$conda$python$nodejs$rust $time
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

[conda]
style = "bold green"
format = "[$symbol$environment]($style) "

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
echo "  1. Set terminal font to: JetBrainsMono Nerd Font"
echo "     VSCode: Terminal › Integrated: Font Family"
echo "     Terminal.app: Preferences → Profiles → Text → Font"
echo "  2. Run: source ~/.zshrc"
echo ""
echo "  Config file: ~/.config/zsh/setup.zsh"
echo "  (Edit that file to customize — it survives conda/nvm rewrites)"
echo "─────────────────────────────────────────────────────────"
