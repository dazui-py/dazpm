# dazpm config

: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

export DAZPM_HOME="${DAZPM_HOME:-$XDG_DATA_HOME/dazpm}"
export DAZPM_CONFIG_DIR="${DAZPM_CONFIG_DIR:-$XDG_CONFIG_HOME/dazpm}"
export DAZPM_CACHE_DIR="${DAZPM_CACHE_DIR:-$XDG_CACHE_HOME/dazpm}"

export DAZPM_PACKAGES_DIR="$DAZPM_HOME/packages"
export DAZPM_BIN_DIR="$DAZPM_HOME/bin"
export DAZPM_FUNCTIONS_DIR="$DAZPM_HOME/functions"
export DAZPM_PLUGINS_DIR="$DAZPM_HOME/plugins"
export DAZPM_COMPLETIONS_DIR="$DAZPM_HOME/completions"
export DAZPM_LOADER="$DAZPM_HOME/init.zsh"
export DAZPM_LOCKFILE="$DAZPM_HOME/dazpm.lock"
