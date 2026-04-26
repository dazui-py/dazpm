source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"

dazpm_update_one() {
  local name="$1"
  local mode="${2:-all}"
  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local type
  type="$(dazpm_record_get "$name" type 2>/dev/null || true)"

  case "$type" in
    git)
      [[ "$mode" == "all" || "$mode" == "git" ]] || return 0

      [[ -d "$pkg_dir/.git" ]] || dazpm_die "not a git package: $name"

      dazpm_ui_header "Updating $name"
      git -C "$pkg_dir" pull --ff-only

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    link)
      [[ "$mode" == "all" || "$mode" == "links" ]] || return 0

      dazpm_ui_header "Refreshing $name"
      dazpm_ui_kv "path" "${pkg_dir:A}"

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    *)
      dazpm_die "missing or invalid record for package: $name"
      ;;
  esac
}

dazpm_update_many() {
  local mode="$1"
  local found=0
  local ok_count=0
  local fail_count=0
  local pkg name

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    name="${pkg:t}"
    found=1

    if ( dazpm_update_one "$name" "$mode" ); then
      ok_count=$((ok_count + 1))
    else
      fail_count=$((fail_count + 1))
      dazpm_warn "failed to update: $name"
    fi
  done

  "$DAZPM_ROOT/bin/dazpm" rebuild

  if [[ "$found" -eq 0 ]]; then
    dazpm_info "no packages installed"
    return 0
  fi

  dazpm_ui_blank
  dazpm_ui_section "Summary"
  dazpm_ui_kv "updated" "$ok_count"
  dazpm_ui_kv "failed" "$fail_count"

  [[ "$fail_count" -eq 0 ]]
}

dazpm_cmd_update() {
  local arg="${1:-}"
  local mode="all"

  command -v git >/dev/null 2>&1 || dazpm_die "git is required"

  case "$arg" in
    ""|--all)
      mode="all"
      dazpm_update_many "$mode"
      ;;

    --git)
      mode="git"
      dazpm_update_many "$mode"
      ;;

    --links|--local)
      mode="links"
      dazpm_update_many "$mode"
      ;;

    -*)
      dazpm_die "unknown option: $arg"
      ;;

    *)
      dazpm_update_one "$arg" "all"
      "$DAZPM_ROOT/bin/dazpm" rebuild
      dazpm_log "updated $arg"
      ;;
  esac
}
