source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_path() {
  dazpm_args_parse "path|p" "" "$@"

  local input
  input="$(dazpm_args_first)"

  [[ -n "$input" ]] || dazpm_die "usage: dazpm path <name> | dazpm path --path <dir>"

  if dazpm_args_has path; then
    local local_path="${input:A}"
    [[ -d "$local_path" ]] || dazpm_die "directory not found: $local_path"
    dazpm_warn "local path, not installed"
    dazpm_ui_raw_or_color "$local_path"
    return 0
  fi

  local pkg_dir="$DAZPM_PACKAGES_DIR/$input"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $input"

  dazpm_ui_raw_or_color "${pkg_dir:A}"
}
