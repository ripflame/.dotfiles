# Apple Silicon Homebrew configuration
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# PATH and MANPATH additions
export PATH="$HOME/go/bin:$HOME/.local/bin:/opt/local/bin:$PATH"
export MANPATH="/opt/homebrew/share/man:$MANPATH"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Preferred editor (env var inherits into subshells)
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Auto-start tmux if not already inside one
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  if [[ -n "$SSH_CONNECTION" ]]; then
    tmux new-session -As ssh
  elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
    tmux new-session -As cursor
  else
    tmux new-session -As main
  fi
fi
