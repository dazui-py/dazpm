dazpm_cmd_commands() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm commands <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local found=0
  local f

  dazpm_ui_header "Commands in $name"

  for f in "$pkg_dir"/bin/*(N); do
    [[ -f "$f" ]] || continue
    found=1
    dazpm_ui_item "${f:t}"
  done

  for f in "$pkg_dir"/functions/*(N); do
    [[ -f "$f" ]] || continue
    found=1
    dazpm_ui_item "${f:t}"
  done

  if [[ "$found" -eq 0 ]]; then
    dazpm_warn "no commands found"
  fi
}
