# dotfiles

Personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- macOS
- Xcode Command Line Tools (for `git`): `xcode-select --install`

## Install on a fresh machine

```sh
git clone <this-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` is idempotent and will:

1. Install Homebrew if missing.
2. Install each package's brew dependencies (skipping any already present).
3. Install [oh-my-zsh](https://ohmyz.sh) and [tpm](https://github.com/tmux-plugins/tpm) if missing.
4. Prompt for your git `user.name` and `user.email`, writing them to `~/.gitconfig.local` (untracked, included by the committed `~/.gitconfig`).
5. `stow` each package into `$HOME`. If a target file already exists and isn't a stow-managed symlink, it's moved into `~/.dotfiles-backup/<timestamp>/` before stowing.
6. Boot-strap tmux plugins via `tpm`.

## Packages

| Package      | Brew deps                              | Targets |
|--------------|----------------------------------------|---------|
| `zsh`        | —                                      | `~/.zshrc` |
| `git`        | `git`, `git-delta`                     | `~/.gitconfig`, `~/.gitignore_global`, `~/.config/git/ignore` |
| `nvim`       | `neovim`                               | `~/.config/nvim/` |
| `tmux`       | `tmux` + `tpm`                         | `~/.tmux.conf` |
| `ghostty`    | `ghostty` (cask)                       | `~/.config/ghostty/` |
| `omz-custom` | (needs oh-my-zsh)                      | `~/.oh-my-zsh/custom/themes/ripflame.zsh-theme` |
| `aerospace`  | `nikitabobko/tap/aerospace` (cask)     | `~/.aerospace.toml` |
| `lsd`        | `lsd`                                  | `~/.config/lsd/` |
| `thefuck`    | `thefuck`                              | `~/.config/thefuck/` |

## Adding a new package

1. Create `~/.dotfiles/<pkg>/` mirroring the `$HOME` tree (e.g. `<pkg>/.config/foo/bar`).
2. Add a new line to the `PACKAGES` array in `install.sh`.
3. `stow -d ~/.dotfiles -t ~ <pkg>` to install it locally, then commit and push.

## Manual stow commands

```sh
stow -d ~/.dotfiles -t ~ -n -v <pkg>   # dry-run
stow -d ~/.dotfiles -t ~ <pkg>         # link
stow -d ~/.dotfiles -t ~ -D <pkg>      # unlink
```
