source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_remove() {
  dazpm_args_parse "dry-run|n" "" "$@"

  local name
  name="$(dazpm_args_first)"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm remove <name> [--dry-run]"

  dazpm_validate_package_name "$name"

  local dest="$DAZPM_PACKAGES_DIR/$name"

  dazpm_lock_acquire

  [[ -e "$dest" ]] || dazpm_die "package not installed: $name"

  dazpm_ui_header "Removing $name"
  dazpm_ui_kv "path" "${dest:A}"

  if dazpm_args_has dry-run; then
    dazpm_warn "dry run, nothing removed"
    return 0
  fi

  dazpm_pkg_unlink_package "${dest:A}"

  rm -rf "$dest"
  dazpm_record_remove "$name"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "removed $name"
}
