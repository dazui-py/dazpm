source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"

dazpm_update_one() {
  local name="$1"
  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local type
  type="$(dazpm_record_get "$name" type 2>/dev/null || true)"

  case "$type" in
    git)
      [[ -d "$pkg_dir/.git" ]] || dazpm_die "not a git package: $name"

      dazpm_log "updating $name"
      git -C "$pkg_dir" pull --ff-only

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    link)
      dazpm_log "refreshing linked package: $name"

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    *)
      dazpm_die "missing or invalid record for package: $name"
      ;;
  esac
}

dazpm_cmd_update() {
  local name="${1:-}"

  command -v git >/dev/null 2>&1 || dazpm_die "git is required"

  if [[ -n "$name" ]]; then
    dazpm_update_one "$name"
    "$DAZPM_ROOT/bin/dazpm" rebuild
    dazpm_log "updated: $name"
    return 0
  fi

  local found=0
  local pkg

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue
    found=1
    dazpm_update_one "${pkg:t}"
  done

  "$DAZPM_ROOT/bin/dazpm" rebuild

  if [[ "$found" -eq 0 ]]; then
    dazpm_log "no packages installed"
  else
    dazpm_log "updated all packages"
  fi
}
