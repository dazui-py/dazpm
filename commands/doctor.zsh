dazpm_cmd_doctor() {
  dazpm_ui_header "Doctor"

  [[ -n "$ZSH_VERSION" ]] \
    && dazpm_log "zsh: ok" \
    || dazpm_warn "not running inside zsh"

  command -v git >/dev/null 2>&1 \
    && dazpm_log "git: ok" \
    || dazpm_warn "git not found"

  [[ -d "$DAZPM_HOME" ]] \
    && dazpm_log "home: $DAZPM_HOME" \
    || dazpm_warn "dazpm home does not exist yet: $DAZPM_HOME"

  [[ -f "$DAZPM_LOADER" ]] \
    && dazpm_log "loader: ok" \
    || dazpm_warn "loader missing, run: dazpm init"

  dazpm_log "done"
}
