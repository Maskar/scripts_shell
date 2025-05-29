export HOMEBREW_PREFIX="$HOME/.linuxbrew"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"

git clone https://github.com/Homebrew/brew "$HOMEBREW_REPOSITORY"

eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"