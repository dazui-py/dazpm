source "$DAZPM_ROOT/lib/source.zsh"
source "$DAZPM_ROOT/lib/git.zsh"
source "$DAZPM_ROOT/lib/package.zsh"

dazpm_cmd_install() {
  local src="${1:-}"

  [[ -n "$src" ]] || dazpm_die "usage: dazpm install <source>"

  dazpm_source_parse "$src"

  local name="$DAZPM_SOURCE_NAME"
  local url="$DAZPM_SOURCE_URL"
  local ref="$DAZPM_SOURCE_REF"
  local dest="$DAZPM_PACKAGES_DIR/$name"

  mkdir -p "$DAZPM_PACKAGES_DIR"

  [[ ! -e "$dest" ]] || dazpm_die "package already installed: $name"

  dazpm_log "installing $name"
  dazpm_log "source: $url"

  dazpm_git_clone "$url" "$ref" "$dest"

  dazpm_pkg_link_package "$name" "$dest"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "installed: $name"
  dazpm_log "run now: source ~/.local/share/dazpm/init.zsh"
}
