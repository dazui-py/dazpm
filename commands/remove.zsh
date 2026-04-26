source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"

dazpm_cmd_remove() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm remove <name>"

  local dest="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$dest" ]] || dazpm_die "package not installed: $name"

  dazpm_pkg_unlink_package "${dest:A}"

  rm -rf "$dest"
  dazpm_record_remove "$name"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "removed: $name"
}
