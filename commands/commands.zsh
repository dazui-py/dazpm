dazpm_cmd_commands() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm commands <name>"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  local found=0
  local f

  for f in "$pkg_dir"/bin/*(N); do
    [[ -f "$f" ]] || continue
    found=1
    print -r -- "${f:t}"
  done

  for f in "$pkg_dir"/functions/*(N); do
    [[ -f "$f" ]] || continue
    found=1
    print -r -- "${f:t}"
  done

  if [[ "$found" -eq 0 ]]; then
    print -r -- "no commands found"
  fi
}
