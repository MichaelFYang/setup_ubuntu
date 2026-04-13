# Terminal Setup

One-script terminal environment setup for **Ubuntu 24.04** and **macOS** (Apple Silicon). Installs modern CLI tools, writes a curated zsh config, and configures a Starship prompt — all in one run.

![Shell](https://img.shields.io/badge/shell-zsh-blue)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20|%20macOS-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

Starting from a fresh install, these scripts transform the default terminal into a productive, modern development environment. Both are **idempotent** — safe to run multiple times without duplicating work.

## What Gets Installed

| # | Tool | Purpose | Ubuntu | macOS |
|:-:|------|---------|:------:|:-----:|
| 1 | [Zsh](https://www.zsh.org/) | Default shell with powerful scripting and completion | apt | built-in |
| 2 | [Homebrew](https://brew.sh/) | Package manager | — | brew |
| 3 | [Starship](https://starship.rs/) | Fast, cross-shell prompt with git integration | curl | brew |
| 4 | [eza](https://github.com/eza-community/eza) | Modern `ls` — icons, git-aware, tree view | apt | brew |
| 5 | [bat](https://github.com/sharkdp/bat) | Modern `cat` — syntax highlighting, line numbers | apt | brew |
| 6 | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for history (`Ctrl+R`) and files (`Ctrl+T`) | apt | brew |
| 7 | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) / [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Ghost-text suggestions and live syntax coloring | apt | brew |
| 8 | [delta](https://github.com/dandavison/delta) | Beautiful side-by-side git diffs | — | brew |
| 9 | [broot](https://github.com/Canop/broot) + tree | Interactive and classic directory viewers | binary | brew |
| — | [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) | Patched font for terminal icon support | curl | brew cask |

## What Gets Configured

- **`~/.config/zsh/setup.zsh`** — History, tab completion, Emacs-style key bindings, and aliases for git, eza, bat, and tree. Includes helper functions: `mkcd`, `extract`, and `f` (quick file search). Sourced from `~/.zshrc` via a single line — survives rewrites by conda, nvm, and similar tools.
- **`~/.config/starship.toml`** — Two-line prompt displaying directory, git branch/status, conda environment, language versions (Python, Node, Rust), command duration, and clock.
- **Conda** — Appends `conda init` block automatically if `~/anaconda3`, `~/miniconda3`, `~/miniforge3`, or `~/mambaforge` is detected.
- **ROS 2 Jazzy** (Ubuntu only) — Sources the workspace setup if `/opt/ros/jazzy/setup.zsh` exists.

## Quick Start

### Ubuntu

```bash
git clone https://github.com/MichaelFYang/terminal-setup.git
cd terminal-setup
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

### macOS

```bash
git clone https://github.com/MichaelFYang/terminal-setup.git
cd terminal-setup
chmod +x setup_macos.sh
./setup_macos.sh
```

### After Installation

1. **Ubuntu**: Log out and back in (or run `zsh`) to activate the new default shell.
2. **Set your terminal font** to **JetBrainsMono Nerd Font** for icon rendering.
   - **VSCode**: Terminal > Integrated: Font Family
   - **Terminal.app** (macOS): Preferences > Profiles > Text > Font
3. Run `source ~/.zshrc` to load the new configuration.

## Aliases Reference

### File Navigation

| Alias | Command |
|-------|---------|
| `ls` | `eza --icons` |
| `ll` | `eza -lh --icons --git` |
| `la` | `eza -lah --icons --git` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat --paging=never` |
| `t2` / `t3` | `tree -L 2` / `tree -L 3` |

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate --color` |
| `gd` | `git diff` |
| `gco` | `git checkout` |

### Utility Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create a directory and `cd` into it |
| `f <pattern>` | Quick case-insensitive file search |
| `extract <file>` | Extract any common archive format |

## Requirements

| Platform | Requirements |
|----------|-------------|
| **Ubuntu** | 24.04 on x86_64 or aarch64 (should work on other Debian-based distros), sudo access |
| **macOS** | Apple Silicon (M1+), admin access for Homebrew |

## Customization

Both scripts write shell configuration to `~/.config/zsh/setup.zsh` and add a single source line to `~/.zshrc`. This design survives tools like conda and nvm that rewrite `~/.zshrc`. To customize after installation, edit `~/.config/zsh/setup.zsh`. The Starship prompt config lives at `~/.config/starship.toml`.

## Acknowledgments

Built with the assistance of [Claude](https://claude.ai) by Anthropic.

## License

This project is licensed under the [MIT License](LICENSE).
