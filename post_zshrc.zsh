
# PATH
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/mysql-client/bin:$PATH"
export PATH="$PATH:/Users/maskar/.cache/lm-studio/bin"


# Aliases
alias mm='micromamba'
alias conda='micromamba'

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(pyenv init --path)"
eval "$(direnv hook zsh)"
eval "$(gh copilot alias -- zsh)"


# FPATH
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Load custom functions and environment variables
source "$HOME/Repos/github/scripts_shell/env_vars.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/misc_fn.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/vpn_fn.zsh"