source "$DAZPM_ROOT/lib/package.zsh"

dazpm_files_show_kind() {
  local pkg_dir="$1"
  local label="$2"
  local kind="$3"

  local file_item rel_file
  local found=0
  local width max

  width="$(dazpm_ui_width)"
  max=$((width - 6))
  [[ "$max" -lt 20 ]] && max=20

  while IFS= read -r file_item; do
    [[ -n "$file_item" ]] || continue
    [[ -f "$file_item" ]] || continue

    if [[ "$found" -eq 0 ]]; then
      dazpm_ui_section "$label"
      found=1
    fi

    rel_file="${file_item#$pkg_dir/}"
    rel_file="$(dazpm_ui_trunc_mid "$rel_file" "$max")"

    dazpm_ui_item "$rel_file"
  done < <(dazpm_pkg_files_by_kind "$pkg_dir" "$kind")

  if [[ "$found" -eq 1 ]]; then
    dazpm_ui_blank
  fi

  return 0
}

dazpm_cmd_files() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm files <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  dazpm_ui_header "Files in $name"
  dazpm_ui_blank

  dazpm_files_show_kind "$pkg_dir" "Bins" "bins"
  dazpm_files_show_kind "$pkg_dir" "Functions" "functions"
  dazpm_files_show_kind "$pkg_dir" "Plugins" "plugins"
  dazpm_files_show_kind "$pkg_dir" "Completions" "completions"
}
