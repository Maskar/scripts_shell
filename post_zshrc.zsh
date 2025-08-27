eval "$(/opt/homebrew/bin/brew shellenv)"


# PATH
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
export PATH="$HOMEBREW_PREFIX/opt/mysql-client/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts_shell/bin:$PATH"sea

# FPATH
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi
if command -v gh &>/dev/null; then
    eval "$(gh copilot alias -- zsh)"
fi
if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi
if command -v uvx &>/dev/null; then
    eval "$(uvx --generate-shell-completion zsh)"
fi
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init - zsh)"
fi




# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)


# Aliases
alias mm='micromamba'
alias conda='micromamba'
alias ls='eza'
alias ll='eza -l --icons'
alias l='eza -la --icons'
alias lt='eza --tree --level=2 --icons'

# Load custom functions and environment variables
source "$HOME/.scripts_shell/env_vars.zsh"
source "$HOME/.scripts_shell/zshfn/misc_fn.zsh"
source "$HOME/.scripts_shell/zshfn/vpn_fn.zsh"


autoload -Uz compinit
compinit