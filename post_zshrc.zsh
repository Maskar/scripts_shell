
# PATH
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/mysql-client/bin:$PATH"
export PATH="$PATH:/Users/maskar/.cache/lm-studio/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Aliases
alias mm='micromamba'
alias conda='micromamba'
alias ls='eza'
alias ll='eza -l --icons'
alias l='eza -la --icons'
alias lt='eza --tree --level=2 --icons'

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(pyenv init --path)"
eval "$(direnv hook zsh)"
eval "$(gh copilot alias -- zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"


# FPATH
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Load custom functions and environment variables
source "$HOME/Repos/github/scripts_shell/env_vars.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/misc_fn.zsh"
source "$HOME/Repos/github/scripts_shell/zshfn/vpn_fn.zsh"
