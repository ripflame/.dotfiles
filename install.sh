#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
NVM_VERSION="${NVM_VERSION:-v0.40.1}"

# pkg : space-separated brew deps; prefix a name with "cask:" for casks.
PACKAGES=(
  "zsh        :"
  "git        : git git-delta"
  "nvim       : neovim fzf bat fd ripgrep tree-sitter lua fswatch deno"
  "tmux       : tmux"
  "ghostty    : cask:ghostty"
  "omz-custom :"
  "aerospace  : cask:nikitabobko/tap/aerospace"
  "lsd        : lsd"
  "thefuck    : thefuck"
)

STOWED=()
SKIPPED=()
FAILED=()

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; }

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || { err "This installer only supports macOS."; exit 1; }
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
    return 0
  fi
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 || { err "Homebrew install failed"; exit 1; }
}

ensure_pkg() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    log "✓ $name already installed"
    return 0
  fi
  log "Installing $name"
  if ! brew install "$name"; then
    err "✗ failed to install $name"
    FAILED+=("brew:$name")
    return 1
  fi
}

ensure_cask() {
  local name="$1"
  if brew list --cask "$name" >/dev/null 2>&1; then
    log "✓ cask $name already installed"
    return 0
  fi
  log "Installing cask $name"
  if ! brew install --cask "$name"; then
    err "✗ failed to install cask $name"
    FAILED+=("cask:$name")
    return 1
  fi
}

ensure_omz() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "✓ oh-my-zsh already installed"
    return 0
  fi
  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

ensure_tpm() {
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "✓ tpm already installed"
    return 0
  fi
  log "Installing tpm"
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}

ensure_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    log "✓ nvm already installed"
    return 0
  fi
  log "Installing nvm $NVM_VERSION"
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

ensure_fzf_git() {
  if [[ -f "$HOME/fzf-git.sh/fzf-git.sh" ]]; then
    log "✓ fzf-git.sh already installed"
    return 0
  fi
  log "Cloning fzf-git.sh"
  git clone https://github.com/junegunn/fzf-git.sh "$HOME/fzf-git.sh"
}

ensure_git_identity() {
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    log "✓ git identity already set (~/.gitconfig.local)"
    return 0
  fi
  log "Configuring git identity (writes to ~/.gitconfig.local, gitignored)"
  local name email
  read -rp "  Git user.name:  " name
  read -rp "  Git user.email: " email
  cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $name
	email = $email
EOF
}

stow_pkg() {
  local pkg="$1"
  local out rel src dst
  out=$(stow -n -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>&1 || true)
  if grep -qE "existing target is (neither a link nor a directory|not owned by stow)" <<<"$out"; then
    warn "Conflicts for $pkg, moving existing targets to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    grep -E "existing target is (neither a link nor a directory|not owned by stow):" <<<"$out" \
      | sed -E 's/.*: //' \
      | while IFS= read -r rel; do
          src="$HOME/$rel"
          dst="$BACKUP_DIR/$rel"
          mkdir -p "$(dirname "$dst")"
          cp -RLv "$src" "$dst"
          rm -f "$src"
        done
  fi
  if stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg" >/dev/null 2>&1; then
    log "✓ stowed $pkg"
    STOWED+=("$pkg")
  else
    # Re-run verbose for the user to see the actual error
    err "✗ failed to stow $pkg:"
    stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>&1 | sed 's/^/    /' >&2 || true
    FAILED+=("stow:$pkg")
  fi
}

main() {
  require_macos
  ensure_brew
  ensure_pkg stow
  ensure_omz
  ensure_tpm
  ensure_nvm
  ensure_fzf_git
  ensure_git_identity

  for entry in "${PACKAGES[@]}"; do
    pkg="${entry%%:*}"; pkg="$(echo "$pkg" | tr -d '[:space:]')"
    deps="${entry#*:}"
    for d in $deps; do
      case "$d" in
        cask:*) ensure_cask "${d#cask:}" || true ;;
        *)      ensure_pkg  "$d"          || true ;;
      esac
    done
    stow_pkg "$pkg"
  done

  # Boot-strap tmux plugins now that ~/.tmux.conf is linked
  if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    log "Running tpm install_plugins"
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" \
      || warn "tpm install_plugins failed — run prefix+I inside tmux instead"
  fi

  echo
  log "Summary:"
  printf '  stowed:  %s\n' "${STOWED[*]:-(none)}"
  printf '  failed:  %s\n' "${FAILED[*]:-(none)}"
  [[ -d "$BACKUP_DIR" ]] && printf '  conflict backups: %s\n' "$BACKUP_DIR"
  [[ ${#FAILED[@]} -eq 0 ]] || exit 1
}

main "$@"
