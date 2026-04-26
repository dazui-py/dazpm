source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

typeset -g DAZPM_UPDATE_DID=0

dazpm_update_one() {
  local name="$1"
  local mode="${2:-all}"
  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  DAZPM_UPDATE_DID=0

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local type
  type="$(dazpm_record_get "$name" type 2>/dev/null || true)"

  case "$type" in
    git)
      [[ "$mode" == "all" || "$mode" == "git" ]] || return 0
      DAZPM_UPDATE_DID=1

      [[ -d "$pkg_dir/.git" ]] || dazpm_die "not a git package: $name"

      dazpm_ui_header "Updating $name"

      if ! git -C "$pkg_dir" pull --ff-only; then
        dazpm_warn "git pull failed: $name"
        return 1
      fi

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    link)
      [[ "$mode" == "all" || "$mode" == "links" ]] || return 0
      DAZPM_UPDATE_DID=1

      dazpm_ui_header "Refreshing $name"
      dazpm_ui_kv "path" "${pkg_dir:A}"

      dazpm_pkg_unlink_package "${pkg_dir:A}"
      dazpm_pkg_link_package "$name" "$pkg_dir"
      ;;

    *)
      DAZPM_UPDATE_DID=1
      dazpm_warn "missing or invalid record for package: $name"
      return 1
      ;;
  esac

  return 0
}

dazpm_update_many() {
  local mode="$1"
  local found=0
  local matched=0
  local ok_count=0
  local fail_count=0
  local pkg name

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    found=1
    name="${pkg:t}"

    if dazpm_update_one "$name" "$mode"; then
      if [[ "$DAZPM_UPDATE_DID" -eq 1 ]]; then
        matched=$((matched + 1))
        ok_count=$((ok_count + 1))
      fi
    else
      if [[ "$DAZPM_UPDATE_DID" -eq 1 ]]; then
        matched=$((matched + 1))
        fail_count=$((fail_count + 1))
      fi
    fi
  done

  "$DAZPM_ROOT/bin/dazpm" rebuild

  if [[ "$found" -eq 0 ]]; then
    dazpm_info "no packages installed"
    return 0
  fi

  dazpm_ui_blank
  dazpm_ui_section "Summary"
  dazpm_ui_kv "matched" "$matched"
  dazpm_ui_kv "updated" "$ok_count"
  dazpm_ui_kv "failed" "$fail_count"

  [[ "$fail_count" -eq 0 ]]
}

dazpm_cmd_update() {
  dazpm_args_parse "git,links|local,all" "" "$@"

  local name
  name="$(dazpm_args_first)"

  local mode="all"

  if dazpm_args_has git && dazpm_args_has links; then
    dazpm_die "choose only one: --git or --links"
  fi

  if dazpm_args_has git; then
    mode="git"
  elif dazpm_args_has links; then
    mode="links"
  else
    mode="all"
  fi

  command -v git >/dev/null 2>&1 || dazpm_die "git is required"

  if [[ -n "$name" ]]; then
    if ! dazpm_update_one "$name" "$mode"; then
      dazpm_die "failed to update: $name"
    fi

    if [[ "$DAZPM_UPDATE_DID" -eq 0 ]]; then
      dazpm_warn "package skipped by selected filter: $name"
      return 0
    fi

    "$DAZPM_ROOT/bin/dazpm" rebuild
    dazpm_log "updated $name"
    return 0
  fi

  dazpm_update_many "$mode"
}
