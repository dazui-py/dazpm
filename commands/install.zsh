source "$DAZPM_ROOT/lib/source.zsh"
source "$DAZPM_ROOT/lib/git.zsh"
source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"

dazpm_cmd_install() {
  local src="${1:-}"

  [[ -n "$src" ]] || dazpm_die "usage: dazpm install <source>"

  dazpm_source_parse "$src"

  local name="$DAZPM_SOURCE_NAME"
  local url="$DAZPM_SOURCE_URL"
  local ref="$DAZPM_SOURCE_REF"
  local dest="$DAZPM_PACKAGES_DIR/$name"

  mkdir -p "$DAZPM_PACKAGES_DIR" "$DAZPM_RECORDS_DIR"

  [[ ! -e "$dest" ]] || dazpm_die "package already installed: $name"

  dazpm_ui_header "Installing $name"
  dazpm_ui_kv "source" "$url"
  [[ -n "$ref" ]] && dazpm_ui_kv "ref" "$ref"
  dazpm_ui_blank

  if ! dazpm_git_clone "$url" "$ref" "$dest"; then
    rm -rf "$dest"
    dazpm_die "git clone failed"
  fi

  if ! dazpm_pkg_validate "$dest"; then
    rm -rf "$dest"
    dazpm_die "invalid package"
  fi

  if ! dazpm_pkg_link_package "$name" "$dest"; then
    rm -rf "$dest"
    dazpm_die "failed to link package"
  fi

  dazpm_record_write "$name" "git" "$src" "$url" "$ref" "$dest"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "installed $name"
  dazpm_info "run: source ~/.local/share/dazpm/init.zsh"
}
