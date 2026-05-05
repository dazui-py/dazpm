# dazpm safety helpers

dazpm_validate_package_name() {
  local name="$1"

  [[ -n "$name" ]] || dazpm_die "missing package name"
  [[ "$name" != "." && "$name" != ".." ]] || dazpm_die "unsafe package name: $name"
  [[ "$name" != */* ]] || dazpm_die "unsafe package name: $name"
  [[ "$name" != *[!A-Za-z0-9._-]* ]] || dazpm_die "unsafe package name: $name"
}

dazpm_lock_release() {
  [[ "${DAZPM_LOCK_HELD:-0}" == "1" ]] || return 0

  rmdir "$DAZPM_LOCKFILE" 2>/dev/null || true
  unset DAZPM_LOCK_HELD
}

dazpm_lock_acquire() {
  [[ "${DAZPM_LOCK_HELD:-0}" == "1" ]] && return 0

  mkdir -p "$DAZPM_HOME"

  if ! mkdir "$DAZPM_LOCKFILE" 2>/dev/null; then
    dazpm_die "another dazpm process is running: $DAZPM_LOCKFILE"
  fi

  export DAZPM_LOCK_HELD=1
  trap 'dazpm_lock_release' EXIT INT TERM
}
