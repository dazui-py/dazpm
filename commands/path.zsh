source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_path() {
  dazpm_args_parse "" "path|p" "$@"

  local input path_opt
  input="$(dazpm_args_first)"
  path_opt="$(dazpm_args_get path "")"

  [[ -n "$input" || -n "$path_opt" ]] || dazpm_die "usage: dazpm path <name> | dazpm path --path <dir>"

  if [[ -n "$path_opt" ]]; then
    local local_path="${path_opt:A}"
    [[ -d "$local_path" ]] || dazpm_die "directory not found: $local_path"
    dazpm_warn "local path, not installed"
    dazpm_ui_raw_or_color "$local_path"
    return 0
  fi

  local name="$input"
  dazpm_validate_package_name "$name"

  local pkg_dir="$DAZPM_PACKAGES_DIR/$name"

  [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"

  dazpm_ui_raw_or_color "${pkg_dir:A}"
}
