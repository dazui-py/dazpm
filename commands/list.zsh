source "$DAZPM_ROOT/lib/record.zsh"

dazpm_list_verbose_table() {
  local found=0
  local pkg name type source ref
  local width source_width source_out

  width="$(dazpm_ui_width)"
  source_width=$(( width - 32 ))
  [[ "$source_width" -lt 20 ]] && source_width=20

  printf "%-20s %-8s %s\n" "PACKAGE" "TYPE" "SOURCE"
  printf "%-20s %-8s %s\n" "-------" "----" "------"

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    found=1
    name="${pkg:t}"
    type="$(dazpm_record_get "$name" type 2>/dev/null || print -r -- "unknown")"
    source="$(dazpm_record_get "$name" source 2>/dev/null || print -r -- "unknown")"
    ref="$(dazpm_record_get "$name" ref 2>/dev/null || true)"

    [[ -n "$ref" ]] && source="$source@$ref"

    name="$(dazpm_ui_trunc "$name" 20)"
    source_out="$(dazpm_ui_trunc_mid "$source" "$source_width")"

    printf "%-20s %-8s %s\n" "$name" "$type" "$source_out"
  done

  [[ "$found" -eq 1 ]] || print -r -- "no packages installed"
}

dazpm_list_verbose_cards() {
  local found=0
  local pkg name type source ref

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -e "$pkg" ]] || continue

    found=1
    name="${pkg:t}"
    type="$(dazpm_record_get "$name" type 2>/dev/null || print -r -- "unknown")"
    source="$(dazpm_record_get "$name" source 2>/dev/null || print -r -- "unknown")"
    ref="$(dazpm_record_get "$name" ref 2>/dev/null || true)"

    [[ -n "$ref" ]] && source="$source@$ref"

    dazpm_ui_section "$name"
    dazpm_ui_card_kv "type" "$type"
    dazpm_ui_card_kv "source" "$source"
    dazpm_ui_blank
  done

  [[ "$found" -eq 1 ]] || print -r -- "no packages installed"
}

dazpm_cmd_list() {
  local verbose=0

  if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
    verbose=1
  fi

  mkdir -p "$DAZPM_PACKAGES_DIR"

  if [[ "$verbose" -eq 0 ]]; then
    local found=0
    local pkg

    for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
      [[ -e "$pkg" ]] || continue
      found=1
      dazpm_ui_item "${pkg:t}"
    done

    [[ "$found" -eq 1 ]] || print -r -- "no packages installed"
    return 0
  fi

  if dazpm_ui_is_narrow; then
    dazpm_list_verbose_cards
  else
    dazpm_list_verbose_table
  fi
}
