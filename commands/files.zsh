dazpm_cmd_files() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm files <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  dazpm_ui_header "Files in $name"

  local f rel width max

  width="$(dazpm_ui_width)"
  max=$(( width - 6 ))
  [[ "$max" -lt 20 ]] && max=20

  for f in "$pkg_dir"/**/*(N.); do
    rel="${f#$pkg_dir/}"
    rel="$(dazpm_ui_trunc_mid "$rel" "$max")"
    dazpm_ui_item "$rel"
  done
}
