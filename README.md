# Setup Ubuntu

A single-script terminal environment setup for **Ubuntu 24.04**. Installs modern CLI tools, writes a curated `.zshrc`, and configures a Starship prompt — all in one run.

![Shell](https://img.shields.io/badge/shell-bash-blue)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

Starting from a fresh Ubuntu install, this script transforms the default terminal into a productive, modern development environment. It is **idempotent** — safe to run multiple times without duplicating work.

## What Gets Installed

| Step | Tool | Purpose |
|:----:|------|---------|
| 1 | [Zsh](https://www.zsh.org/) | Default shell with powerful scripting and completion |
| 2 | Git, curl, wget, unzip, fontconfig | Essential build and download utilities |
| 3 | [Starship](https://starship.rs/) | Fast, cross-shell prompt with git integration |
| 4 | [eza](https://github.com/eza-community/eza) | Modern `ls` — icons, git-aware, tree view |
| 5 | [bat](https://github.com/sharkdp/bat) | Modern `cat` — syntax highlighting, line numbers |
| 6 | [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for history (`Ctrl+R`) and files (`Ctrl+T`) |
| 7 | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) / [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Ghost-text suggestions and live syntax coloring |
| 8 | [broot](https://github.com/Canop/broot) + tree | Interactive and classic directory viewers |
| — | [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) | Patched font for terminal icon support |

## What Gets Configured

- **`.zshrc`** — History, tab completion, Emacs-style key bindings, and aliases for git, eza, bat, and tree. Includes helper functions: `mkcd`, `extract`, and `f` (quick file search).
- **`starship.toml`** — Two-line prompt displaying directory, git branch/status, language versions (Python, Node, Rust), command duration, and clock.
- **Conda** — Appends `conda init` block automatically if `~/anaconda3`, `~/miniconda3`, `~/miniforge3`, or `~/mambaforge` is detected.
- **ROS 2 Jazzy** — Sources the workspace setup if `/opt/ros/jazzy/setup.zsh` exists.

## Quick Start

```bash
git clone https://github.com/MichaelFYang/setup_ubuntu.git
cd setup_ubuntu
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

### After Installation

1. **Log out and back in** (or run `zsh`) to activate the new default shell.
2. **Set your terminal font** to **JetBrainsMono Nerd Font** for icon rendering.
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

- **Ubuntu 24.04** on **x86_64** or **aarch64** (should work on other Debian-based distributions with minor adjustments)
- **sudo** access for package installation

## Customization

The script writes all shell configuration to `~/.config/zsh/setup.zsh` and adds a single source line to `~/.zshrc`. This design survives tools like conda and nvm that rewrite `~/.zshrc`. To customize after installation, edit `~/.config/zsh/setup.zsh`. The Starship prompt config lives at `~/.config/starship.toml`.

## License

This project is licensed under the [MIT License](LICENSE).
