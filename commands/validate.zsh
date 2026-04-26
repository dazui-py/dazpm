source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/manifest.zsh"

dazpm_validate_kind_rules() {
  local pkg_dir="$1"
  local kind="$2"
  local file_item rel_file base_name

  while IFS= read -r file_item; do
    [[ -n "$file_item" ]] || continue
    [[ -f "$file_item" ]] || continue

    rel_file="${file_item#$pkg_dir/}"
    base_name="${file_item:t}"

    case "$kind" in
      plugins)
        [[ "$base_name" == *.zsh ]] || dazpm_die "plugin must end with .zsh: $rel_file"
        ;;

      completions)
        [[ "$base_name" == _* ]] || dazpm_die "zsh completion must start with _: $rel_file"
        ;;

      functions)
        [[ "$base_name" != *.* ]] || dazpm_warn "autoload function usually should not have extension: $rel_file"
        ;;

      bins)
        [[ -x "$file_item" ]] || dazpm_warn "bin is not executable yet: $rel_file"
        ;;
    esac
  done < <(dazpm_pkg_files_by_kind "$pkg_dir" "$kind")

  return 0
}

dazpm_cmd_validate() {
  local pkg_dir="${1:-.}"

  pkg_dir="${pkg_dir:A}"

  [[ -d "$pkg_dir" ]] || dazpm_die "directory not found: $pkg_dir"

  dazpm_ui_header "Validating package"
  dazpm_ui_kv "path" "$pkg_dir"
  dazpm_ui_blank

  dazpm_pkg_validate "$pkg_dir"

  if dazpm_manifest_exists "$pkg_dir"; then
    dazpm_log "manifest: ok"

    local manifest_name manifest_version

    manifest_name="$(dazpm_manifest_get_value "$pkg_dir" "" "name" 2>/dev/null || true)"
    manifest_version="$(dazpm_manifest_get_value "$pkg_dir" "" "version" 2>/dev/null || true)"

    [[ -n "$manifest_name" ]] && dazpm_ui_kv "name" "$manifest_name"
    [[ -n "$manifest_version" ]] && dazpm_ui_kv "version" "$manifest_version"
  else
    dazpm_warn "no daz.toml found, using legacy layout"
  fi

  dazpm_validate_kind_rules "$pkg_dir" "bins"
  dazpm_validate_kind_rules "$pkg_dir" "plugins"
  dazpm_validate_kind_rules "$pkg_dir" "functions"
  dazpm_validate_kind_rules "$pkg_dir" "completions"

  dazpm_log "valid package"
}
