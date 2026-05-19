# Apple Silicon Homebrew configuration
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="ripflame"

# Config aliases
alias configz="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
HIST_STAMPS="dd/mm/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# ~/.zshrc
timestamp() {
  date +"%Y%m%d%H%M%S"
}

# Commit generator
unalias gc 2>/dev/null
gc() {
  if [ -z "$(git diff --cached --name-only)" ]; then
    echo "Nothing staged."
    echo -n "Stage all files? (y/n) "
    read -r yn
    if [[ "$yn" == "y" ]]; then
      git add -A
    else
      echo "Cancelled."
      return 1
    fi
  fi

  echo "Generating commit message..."
  local msg
  # msg=$(git diff --cached | claude --print "You are a git commit message generator. Given this diff, write a conventional commit message. Format: type(scope): description. Types: feat, fix, chore, docs, refactor, test, style, perf. Keep the first line under 72 chars. Add a body only if the change is complex. Output ONLY the message.")
  msg=$(printf "Files changed:\n%s\n\nDiff (truncated):\n%s" \
    "$(git diff --cached --stat)" \
    "$(git diff --cached -- ':(exclude)*.svg' ':(exclude)*.png' ':(exclude)*.jpg' ':(exclude)*.jpeg' ':(exclude)*.gif' ':(exclude)package-lock.json' ':(exclude)*.lock' | head -400)" \
    | claude --print "Generate a conventional commit message for this diff. Format: type(scope): description. Types: feat, fix, chore, docs, refactor, test, style, perf. Subject under 72 chars (aim for 50), imperative mood, lowercase after colon, no period. Add a body only if the change is non-obvious — explain why, not what. Wrap body at 72 chars. Output ONLY the raw message, no markdown fences or commentary.")

  if [ $? -ne 0 ] || [ -z "$msg" ]; then
    echo "Failed to generate message."
    return 1
  fi

  echo -e "\n--- Proposed commit message ---"
  echo "$msg"
  echo "-------------------------------"
  echo -n "(a)ccept, (e)dit, (r)egenerate, (c)ancel? "
  read -r choice

  case "$choice" in
    a) git commit -m "$msg" ;;
    e) git commit -e -m "$msg" ;;  # Opens in $EDITOR (vim for you)
    r) gc ;;  # Try again
    c) echo "Cancelled." ;;
    *) echo "Cancelled." ;;
  esac
}

# Apple Silicon Homebrew first, then your custom paths, then Intel as fallback
export PATH="$HOME/go/bin:$HOME/.local/bin:/opt/local/bin:$PATH"
export MANPATH="/opt/homebrew/share/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Source alias files
if [ -f ~/.secrets ]; then
  source ~/.secrets
fi

# Fix locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/ripflame/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# setup fzf key bindings
eval "$(fzf --zsh)"

# Ctrl+R inside fzf history steps to the next (older) match
export FZF_CTRL_R_OPTS="--bind 'ctrl-r:up'"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/fzf-git.sh/fzf-git.sh

eval $(thefuck --alias)
