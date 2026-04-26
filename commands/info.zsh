source "$DAZPM_ROOT/lib/record.zsh"

dazpm_cmd_info() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm info <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local type source url ref real_path

  type="$(dazpm_record_get "$name" type 2>/dev/null || print -r -- "unknown")"
  source="$(dazpm_record_get "$name" source 2>/dev/null || print -r -- "unknown")"
  url="$(dazpm_record_get "$name" url 2>/dev/null || print -r -- "")"
  ref="$(dazpm_record_get "$name" ref 2>/dev/null || print -r -- "")"
  real_path="${pkg_dir:A}"

  dazpm_ui_header "$name"
  dazpm_ui_kv "type" "$type"
  dazpm_ui_kv "source" "$source"
  [[ -n "$url" ]] && dazpm_ui_kv "url" "$url"
  [[ -n "$ref" ]] && dazpm_ui_kv "ref" "$ref"
  dazpm_ui_kv "path" "$real_path"

  if [[ -d "$pkg_dir/.git" ]]; then
    local commit branch remote

    commit="$(git -C "$pkg_dir" rev-parse --short HEAD 2>/dev/null || true)"
    branch="$(git -C "$pkg_dir" branch --show-current 2>/dev/null || true)"
    remote="$(git -C "$pkg_dir" remote get-url origin 2>/dev/null || true)"

    [[ -n "$branch" ]] && dazpm_ui_kv "branch" "$branch"
    [[ -n "$commit" ]] && dazpm_ui_kv "commit" "$commit"
    [[ -n "$remote" ]] && dazpm_ui_kv "remote" "$remote"
  fi
}
