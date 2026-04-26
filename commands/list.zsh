dazpm_cmd_list() {
  mkdir -p "$DAZPM_PACKAGES_DIR"

  local found=0

  for pkg in "$DAZPM_PACKAGES_DIR"/*(N); do
    [[ -d "$pkg" ]] || continue
    found=1
    print -r -- "${pkg:t}"
  done

  if [[ "$found" -eq 0 ]]; then
    print -r -- "no packages installed"
  fi
}
