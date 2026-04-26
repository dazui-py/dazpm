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

  print -r -- "name: $name"
  print -r -- "type: $type"
  print -r -- "source: $source"

  [[ -n "$url" ]] && print -r -- "url: $url"
  [[ -n "$ref" ]] && print -r -- "ref: $ref"

  print -r -- "path: $real_path"

  if [[ -d "$pkg_dir/.git" ]]; then
    local commit branch
    commit="$(git -C "$pkg_dir" rev-parse --short HEAD 2>/dev/null || true)"
    branch="$(git -C "$pkg_dir" branch --show-current 2>/dev/null || true)"

    [[ -n "$branch" ]] && print -r -- "branch: $branch"
    [[ -n "$commit" ]] && print -r -- "commit: $commit"
  fi
}
