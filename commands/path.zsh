dazpm_cmd_path() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm path <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  dazpm_ui_raw_or_color "${pkg_dir:A}"
}
