setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# Env root folders
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$XDG_CONFIG_HOME/.oh-my-zsh"
export PYENV_ROOT="$XDG_CONFIG_HOME/.pyenv"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"

if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "brew missing!"
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
else
  echo "pyenv missing!"
fi

# PATH
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/mysql-client/bin:$PATH"
export PATH="$PATH:/Users/maskar/.cache/lm-studio/bin"

# FPATH
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"


# Editor selection
if command -v micro >/dev/null 2>&1; then
  export EDITOR="micro"
else
  export EDITOR="nano"
fi
export VISUAL=$EDITOR
export HOMEBREW_EDITOR=$EDITOR

# Env Managers
# export CONDARC="$XDG_CONFIG_HOME/.condarc"
export MAMBA_CONFIG_FILE="$XDG_CONFIG_HOME/mamba/mambarc"
export MAMBA_EXE="$HOMEBREW_PREFIX/opt/micromamba/bin/micromamba"
export MAMBA_NO_ROOT_ENV=1

export HOMEBREW_CASK_OPTS="--no-quarantine"

# Themes
export SPACESHIP_CONFIG="$XDG_CONFIG_HOME/zsh/spaceship.zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

export LESS="-SRXF"


# Aliases
alias mm='micromamba'
alias conda='micromamba'

source "$HOME/Repos/github/scripts_shell/env_vars.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/misc_fn.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/vpn_fn.zsh"



