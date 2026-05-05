source "$DAZPM_ROOT/lib/source.zsh"
source "$DAZPM_ROOT/lib/git.zsh"
source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_install() {
  dazpm_args_parse "force|f" "name|n,ref|r" "$@"

  local src
  src="$(dazpm_args_first)"

  [[ -n "$src" ]] || dazpm_die "usage: dazpm install <source> [options]"

  dazpm_source_parse "$src"

  local name="$DAZPM_SOURCE_NAME"
  local url="$DAZPM_SOURCE_URL"
  local ref="$DAZPM_SOURCE_REF"

  local opt_name opt_ref
  opt_name="$(dazpm_args_get name "")"
  opt_ref="$(dazpm_args_get ref "")"

  [[ -n "$opt_name" ]] && name="$opt_name"
  [[ -n "$opt_ref" ]] && ref="$opt_ref"

  dazpm_validate_package_name "$name"

  local dest="$DAZPM_PACKAGES_DIR/$name"

  dazpm_lock_acquire

  mkdir -p "$DAZPM_PACKAGES_DIR" "$DAZPM_RECORDS_DIR"

  if [[ -e "$dest" ]]; then
    if dazpm_args_has force; then
      dazpm_warn "overwriting existing package: $name"
      dazpm_pkg_unlink_package "${dest:A}"
      rm -rf "$dest"
      dazpm_record_remove "$name"
    else
      dazpm_die "package already installed: $name"
    fi
  fi

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
}
