dazpm_cmd_doctor() {
  dazpm_log "checking environment"

  [[ -n "$ZSH_VERSION" ]] || dazpm_warn "not running inside zsh"

  if command -v git >/dev/null 2>&1; then
    dazpm_log "git: ok"
  else
    dazpm_warn "git not found"
  fi

  if [[ -d "$DAZPM_HOME" ]]; then
    dazpm_log "home: $DAZPM_HOME"
  else
    dazpm_warn "dazpm home does not exist yet: $DAZPM_HOME"
  fi

  if [[ -f "$DAZPM_LOADER" ]]; then
    dazpm_log "loader: ok"
  else
    dazpm_warn "loader missing, run: dazpm init"
  fi

  dazpm_log "done"
}
