dazpm_cmd_files() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm files <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  find "$pkg_dir" -type f | sed "s#${pkg_dir:A}/##" | sort
}
