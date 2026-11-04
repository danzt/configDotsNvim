<div align="center">

# ~/.config

**A keyboard-driven macOS terminal environment, reproducible with one command.**

Neovim · herdr · Ghostty · AeroSpace · Karabiner · Zsh

</div>

---

## What you get

| Layer | Tool | Role |
| --- | --- | --- |
| Editor | [Neovim](https://neovim.io) + [LazyVim](https://www.lazyvim.org) | Main editor, with Claude and CodeCompanion integrations |
| Workspace | [herdr](https://herdr.dev) | Terminal workspace manager for AI coding agents |
| Terminal | [Ghostty](https://ghostty.org) | Default terminal, quits fully when its last window closes |
| Window manager | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | i3-style tiling |
| Keyboard | [Karabiner-Elements](https://karabiner-elements.pqrs.org) | Caps Lock becomes the window-manager modifier |
| Bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) + [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Workspace bar and window borders |
| Shells | Zsh (main), Nushell, Fish | Zsh with oh-my-zsh, Powerlevel10k, atuin, zoxide, fzf, carapace |
| Extras | WezTerm, Kitty, Zellij | Alternative terminals and multiplexer |

Herdr uses the `tokyo-night` theme, a bottom tab bar with a status area, and a collapsed sidebar (toggle it with `prefix` + `b`).

## Quick start

On a fresh Mac:

```bash
git clone https://github.com/danzt/configDotsNvim.git ~/.config
cd ~/.config
git checkout luaDots
./bootstrap.sh
```

`bootstrap.sh` is idempotent, so running it again skips whatever is already installed. It will:

1. Install Homebrew if it is missing.
2. Install every package, cask and font from the [`Brewfile`](Brewfile).
3. Install herdr with its official installer.
4. Install Zellij with cargo.
5. Install oh-my-zsh.
6. Link `~/.zshrc` to [`zsh/.zshrc`](zsh/.zshrc), backing up any existing file as `~/.zshrc.bak`.

## After the install

Credentials are never stored in this repository. Set these up by hand:

- [ ] `gh auth login`
- [ ] Store your API keys in the macOS Keychain. The zshrc reads `notion-api-key`, `github-personal-access-token`, `figma-token` and `gemini-api-key`.
- [ ] Open Neovim once so lazy.nvim installs the plugins pinned in `nvim/lazy-lock.json`.
- [ ] Grant Accessibility and Input Monitoring permissions to AeroSpace and Karabiner-Elements.
- [ ] Restart your terminal. Ghostty will start herdr automatically.

## How it fits together

```text
Caps Lock ──Karabiner──▶ Cmd+Ctrl+Alt ──▶ AeroSpace   (windows and workspaces)
Ghostty ──zshrc autostart──▶ herdr                    (agents, panes, tabs)
herdr pane ──▶ Neovim / Claude Code / Codex
```

- **Caps Lock is the window-manager key.** Karabiner maps it to `Cmd+Ctrl+Alt`, and AeroSpace uses that as its modifier. For example, Caps + Enter opens a new Ghostty window.
- **herdr starts on its own.** `start_if_needed` in the zshrc runs `exec herdr` in every new interactive terminal that is not already inside herdr.
- **herdr prefix is the backtick key.** `prefix` + `alt` + `m` opens the YouTube Music panel (`ytrail`) as a popup.
- **Plain Alt belongs to herdr.** Never bind `Cmd+Ctrl+Alt` combinations there, because AeroSpace owns them.

## Repository layout

| Path | Contents |
| --- | --- |
| `nvim/` | Neovim config on LazyVim, including the Claude rail and CodeCompanion setup |
| `herdr/` | herdr theme, sidebar rows, key bindings and popup commands |
| `ghostty/` | Ghostty config |
| `aerospace/` | Tiling rules and key bindings |
| `karabiner/` | Keyboard remaps |
| `sketchybar/`, `borders/` | Status bar and window borders |
| `zsh/` | The tracked `.zshrc`, linked to `~` by the bootstrap |
| `fish/`, `nushell/` | Alternative shell configs |
| `wezterm/`, `kitty/`, `zellij/` | Alternative terminal and multiplexer configs |
| `atuin/`, `gga/`, `git/` | Shell history, GGA and global git ignore |
| `ytrail/` | YouTube Music panel used from herdr |
| `claude/` | Claude Code hooks and status line |
| `Brewfile`, `bootstrap.sh` | Everything needed to rebuild the machine |

## Updating

Edit the files in place, since `~/.config` is the repository itself. The one exception is the zshrc: `~/.zshrc` is a link, so edit `zsh/.zshrc` directly.

To pin a new package, add it to the `Brewfile`.

## Notes

- Targets macOS on Apple Silicon.
- Credentials, caches and machine-local state are excluded by [`.gitignore`](.gitignore). If you fork this, check it before adding anything new.
- Licensed under the terms in [`LICENSE`](LICENSE).
