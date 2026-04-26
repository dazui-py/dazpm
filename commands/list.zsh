source "$DAZPM_ROOT/lib/record.zsh"

dazpm_cmd_list() {
  local verbose=0

  if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
    verbose=1
  fi

  mkdir -p "$DAZPM_PACKAGES_DIR"

  local found=0
  local pkg name type source ref

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    found=1
    name="${pkg:t}"

    if [[ "$verbose" -eq 0 ]]; then
      print -r -- "$name"
      continue
    fi

    type="$(dazpm_record_get "$name" type 2>/dev/null || print -r -- "unknown")"
    source="$(dazpm_record_get "$name" source 2>/dev/null || print -r -- "unknown")"
    ref="$(dazpm_record_get "$name" ref 2>/dev/null || true)"

    if [[ -n "$ref" ]]; then
      print -r -- "$name [$type] $source @$ref"
    else
      print -r -- "$name [$type] $source"
    fi
  done

  if [[ "$found" -eq 0 ]]; then
    print -r -- "no packages installed"
  fi
}
