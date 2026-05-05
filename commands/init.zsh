dazpm_cmd_init() {
  dazpm_lock_acquire

  mkdir -p \
    "$DAZPM_PACKAGES_DIR" \
    "$DAZPM_RECORDS_DIR" \
    "$DAZPM_BIN_DIR" \
    "$DAZPM_FUNCTIONS_DIR" \
    "$DAZPM_PLUGINS_DIR" \
    "$DAZPM_COMPLETIONS_DIR" \
    "$DAZPM_CONFIG_DIR" \
    "$DAZPM_CACHE_DIR"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  local rc_file="$HOME/.zshrc"
  local line='[ -f "$HOME/.local/share/dazpm/init.zsh" ] && source "$HOME/.local/share/dazpm/init.zsh"'

  touch "$rc_file"

  if grep -Fq "$line" "$rc_file"; then
    dazpm_log "already initialized in $rc_file"
  else
    {
      print
      print "# dazpm"
      print "$line"
    } >> "$rc_file"

    dazpm_log "added loader to $rc_file"
  fi

  dazpm_log "restart zsh or run: source ~/.zshrc"
}
