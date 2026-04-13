# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Two standalone shell scripts that set up a modern zsh terminal environment from scratch. Each script is self-contained (no shared libraries or dependencies between them):

- **`setup_ubuntu.sh`** (bash) -- Ubuntu 24.04, x86_64/aarch64. Uses apt + manual binary downloads.
- **`setup_macos.sh`** (zsh) -- macOS Apple Silicon. Uses Homebrew for everything.

There is no build system, test suite, or linter. To validate changes, read through the script logic and test on the target platform.

## Architecture

Both scripts follow the same structure:

1. **Tool installation** -- numbered steps, each guarded by `command -v` or `dpkg -s` checks for idempotency.
2. **Embedded shell config** -- a full `~/.config/zsh/setup.zsh` is written inline via heredoc. This file contains all aliases, keybindings, plugin sources, and prompt init.
3. **Embedded Starship config** -- `~/.config/starship.toml` is written inline via heredoc (identical in both scripts).
4. **Source line injection** -- a single line is prepended to `~/.zshrc` to source `setup.zsh`. This indirection protects config from being overwritten by conda/nvm/rustup.
5. **Conda detection** -- scans for `anaconda3`, `miniconda3`, `miniforge3`, `mambaforge` and appends `conda init` block to `setup.zsh`.

### Key design decisions

- **Config lives in `~/.config/zsh/setup.zsh`**, not `~/.zshrc` directly. Tools that rewrite `~/.zshrc` (conda, nvm) only add their own blocks; the source line survives.
- **Idempotent** -- every install step checks before acting. Safe to re-run.
- **broot cleanup** -- after `broot --install`, both scripts remove broot's hardcoded `.zshrc` patches since `setup.zsh` already sources the launcher.
- **Ubuntu `bat` symlink** -- Ubuntu packages bat as `batcat`; a symlink to `~/.local/bin/bat` is always created.

### Platform differences

| Concern | Ubuntu | macOS |
|---------|--------|-------|
| Package manager | apt (+ curl/wget for starship, broot, nerd font) | Homebrew |
| delta (git diff) | Not installed | Installed + git config set |
| zsh plugins path | `/usr/share/zsh-*/` | `/opt/homebrew/share/zsh-*/` |
| Homebrew init | N/A | `eval "$(/opt/homebrew/bin/brew shellenv)"` at top of setup.zsh |
| ROS 2 Jazzy | Sources `/opt/ros/jazzy/setup.zsh` if present | N/A |

## When editing these scripts

- The zsh config and Starship config are **duplicated** across both scripts as inline heredocs. Changes to aliases, keybindings, prompt format, etc. likely need to be applied to both files.
- Preserve the `set -e` at the top -- both scripts fail fast on errors.
- New tool installations should follow the existing pattern: check if already installed, install if not, print status with the checkmark/warning prefix convention (`✓` / `⚠`).
