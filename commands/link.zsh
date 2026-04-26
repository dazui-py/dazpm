source "$DAZPM_ROOT/lib/package.zsh"

dazpm_cmd_link() {
  local pkg_path="${1:-}"
  local name="${2:-}"

  [[ -n "$pkg_path" ]] || dazpm_die "usage: dazpm link <path> [name]"

  pkg_path="${pkg_path:A}"

  [[ -d "$pkg_path" ]] || dazpm_die "directory not found: $pkg_path"

  [[ -n "$name" ]] || name="${pkg_path:t}"

  if [[ "$name" == *[!A-Za-z0-9._-]* ]]; then
    dazpm_die "unsafe package name: $name"
  fi

  local dest="$DAZPM_PACKAGES_DIR/$name"

  mkdir -p "$DAZPM_PACKAGES_DIR"

  [[ ! -e "$dest" ]] || dazpm_die "package already exists: $name"

  dazpm_pkg_validate "$pkg_path"

  ln -s "$pkg_path" "$dest"

  dazpm_pkg_link_package "$name" "$dest"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "linked local package: $name"
  dazpm_log "run now: source ~/.local/share/dazpm/init.zsh"
}
