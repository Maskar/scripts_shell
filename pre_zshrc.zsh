setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# Env root folders
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$XDG_CONFIG_HOME/.oh-my-zsh"
export PYENV_ROOT="$XDG_CONFIG_HOME/.pyenv"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"



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
export MAMBA_NO_ROOT_ENV=1

export HOMEBREW_CASK_OPTS="--no-quarantine"

# Themes
export SPACESHIP_CONFIG="$XDG_CONFIG_HOME/zsh/spaceship.zsh"

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  # Settings for Cursor/VS Code terminal
  ZSH_THEME="gozilla"
  # Add other customizations here
else
  # Settings for your regular terminal
  ZSH_THEME="powerlevel10k/powerlevel10k"
  # Add other customizations here
fi

export LESS="-SRXF"






