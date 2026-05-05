source "$DAZPM_ROOT/lib/record.zsh"

dazpm_cmd_repair() {
  mkdir -p "$DAZPM_RECORDS_DIR"

  local pkg name real

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    name="${pkg:t}"

    if dazpm_record_exists "$name"; then
      continue
    fi

    real="${pkg:A}"

    if [[ -L "$pkg" ]]; then
      dazpm_record_write "$name" "link" "$real" "" "" "$real"
      dazpm_log "repaired linked package: $name"
    elif [[ -d "$pkg/.git" ]]; then
      local url
      url="$(git -C "$pkg" remote get-url origin 2>/dev/null || true)"
      dazpm_record_write "$name" "git" "$url" "$url" "" "$pkg"
      dazpm_log "repaired git package: $name"
    else
      dazpm_warn "could not repair package without git or symlink: $name"
    fi
  done

  "$DAZPM_ROOT/bin/dazpm" rebuild
  dazpm_log "repair done"
}
