source "$DAZPM_ROOT/lib/record.zsh"
source "$DAZPM_ROOT/lib/manifest.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_info() {
  dazpm_args_parse "path|p" "" "$@"

  local input
  input="$(dazpm_args_first)"

  [[ -n "$input" ]] || dazpm_die "usage: dazpm info <name> | dazpm info --path <dir>"

  local name pkg_dir is_local
  is_local=0

  if dazpm_args_has path; then
    pkg_dir="${input:A}"
    [[ -d "$pkg_dir" ]] || dazpm_die "directory not found: $pkg_dir"
    name="${pkg_dir:t}"
    is_local=1
    dazpm_warn "inspecting local package, not installed"
  else
    name="$input"
    pkg_dir="$DAZPM_PACKAGES_DIR/$name"
    [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"
    pkg_dir="${pkg_dir:A}"
  fi

  dazpm_ui_header "$name"

  if [[ "$is_local" -eq 1 ]]; then
    dazpm_ui_kv "type" "local"
  else
    local record_type record_source record_url record_ref

    record_type="$(dazpm_record_get "$name" type 2>/dev/null || print -r -- "unknown")"
    record_source="$(dazpm_record_get "$name" source 2>/dev/null || print -r -- "unknown")"
    record_url="$(dazpm_record_get "$name" url 2>/dev/null || print -r -- "")"
    record_ref="$(dazpm_record_get "$name" ref 2>/dev/null || print -r -- "")"

    dazpm_ui_kv "type" "$record_type"
    dazpm_ui_kv "source" "$record_source"
    [[ -n "$record_url" ]] && dazpm_ui_kv "url" "$record_url"
    [[ -n "$record_ref" ]] && dazpm_ui_kv "ref" "$record_ref"
  fi

  dazpm_ui_kv "path" "$pkg_dir"

  if dazpm_manifest_exists "$pkg_dir"; then
    local manifest_name manifest_version manifest_description manifest_author manifest_license
    local tag tags_out

    manifest_name="$(dazpm_manifest_get_value "$pkg_dir" "" "name" 2>/dev/null || true)"
    manifest_version="$(dazpm_manifest_get_value "$pkg_dir" "" "version" 2>/dev/null || true)"
    manifest_description="$(dazpm_manifest_get_value "$pkg_dir" "" "description" 2>/dev/null || true)"
    manifest_author="$(dazpm_manifest_get_value "$pkg_dir" "" "author" 2>/dev/null || true)"
    manifest_license="$(dazpm_manifest_get_value "$pkg_dir" "" "license" 2>/dev/null || true)"

    tags_out=""

    while IFS= read -r tag; do
      [[ -n "$tag" ]] || continue

      if [[ -z "$tags_out" ]]; then
        tags_out="$tag"
      else
        tags_out="$tags_out, $tag"
      fi
    done < <(dazpm_manifest_get_array "$pkg_dir" "meta" "tags" 2>/dev/null)

    dazpm_ui_blank
    dazpm_ui_section "Manifest"
    [[ -n "$manifest_name" ]] && dazpm_ui_kv "name" "$manifest_name"
    [[ -n "$manifest_version" ]] && dazpm_ui_kv "version" "$manifest_version"
    [[ -n "$manifest_description" ]] && dazpm_ui_kv "desc" "$manifest_description"
    [[ -n "$manifest_author" ]] && dazpm_ui_kv "author" "$manifest_author"
    [[ -n "$manifest_license" ]] && dazpm_ui_kv "license" "$manifest_license"
    [[ -n "$tags_out" ]] && dazpm_ui_kv "tags" "$tags_out"
  fi

  if [[ -d "$pkg_dir/.git" ]]; then
    local commit branch remote_url

    commit="$(git -C "$pkg_dir" rev-parse --short HEAD 2>/dev/null || true)"
    branch="$(git -C "$pkg_dir" branch --show-current 2>/dev/null || true)"
    remote_url="$(git -C "$pkg_dir" remote get-url origin 2>/dev/null || true)"

    dazpm_ui_blank
    dazpm_ui_section "Git"
    [[ -n "$branch" ]] && dazpm_ui_kv "branch" "$branch"
    [[ -n "$commit" ]] && dazpm_ui_kv "commit" "$commit"
    [[ -n "$remote_url" ]] && dazpm_ui_kv "remote" "$remote_url"
  fi
}
