source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/record.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_link() {
  dazpm_args_parse "" "name|n" "$@"

  local pkg_path name
  pkg_path="$(dazpm_args_first)"
  name="$(dazpm_args_get name "")"

  [[ -n "$pkg_path" ]] || dazpm_die "usage: dazpm link <path> [name]"

  pkg_path="${pkg_path:A}"

  [[ -d "$pkg_path" ]] || dazpm_die "directory not found: $pkg_path"

  if [[ -z "$name" && "${#DAZPM_ARGS[@]}" -ge 2 ]]; then
    name="${DAZPM_ARGS[2]}"
  fi

  [[ -n "$name" ]] || name="${pkg_path:t}"

  if [[ "$name" == *[!A-Za-z0-9._-]* ]]; then
    dazpm_die "unsafe package name: $name"
  fi

  local dest="$DAZPM_PACKAGES_DIR/$name"

  mkdir -p "$DAZPM_PACKAGES_DIR" "$DAZPM_RECORDS_DIR"

  [[ ! -e "$dest" ]] || dazpm_die "package already exists: $name"

  dazpm_pkg_validate "$pkg_path"

  ln -s "$pkg_path" "$dest"

  dazpm_pkg_link_package "$name" "$dest"

  dazpm_record_write "$name" "link" "$pkg_path" "" "" "$pkg_path"

  "$DAZPM_ROOT/bin/dazpm" rebuild

  dazpm_log "linked local package: $name"
}
