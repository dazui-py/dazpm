source "$DAZPM_ROOT/lib/manifest.zsh"

dazpm_pkg_files_by_kind() {
  local pkg_dir="$1"
  local kind="$2"
  local file_item

  if dazpm_manifest_exists "$pkg_dir"; then
    dazpm_manifest_install_files "$pkg_dir" "$kind"
    return 0
  fi

  case "$kind" in
    bins)
      for file_item in "$pkg_dir"/bin/*(N); do
        [[ -f "$file_item" ]] && print -r -- "$file_item"
      done
      ;;

    plugins)
      for file_item in "$pkg_dir"/plugins/*.zsh(N); do
        [[ -f "$file_item" ]] && print -r -- "$file_item"
      done
      ;;

    functions)
      for file_item in "$pkg_dir"/functions/*(N); do
        [[ -f "$file_item" ]] && print -r -- "$file_item"
      done
      ;;

    completions)
      for file_item in "$pkg_dir"/completions/zsh/_*(N); do
        [[ -f "$file_item" ]] && print -r -- "$file_item"
      done
      ;;

    *)
      dazpm_die "unknown package file kind: $kind"
      ;;
  esac
}

dazpm_pkg_validate() {
  local pkg_dir="$1"
  local count=0
  local file_item

  [[ -d "$pkg_dir" ]] || dazpm_die "package directory not found: $pkg_dir"

  if dazpm_manifest_exists "$pkg_dir"; then
    dazpm_manifest_validate "$pkg_dir"
    return 0
  fi

  for file_item in \
    "$pkg_dir"/bin/*(N) \
    "$pkg_dir"/functions/*(N) \
    "$pkg_dir"/plugins/*.zsh(N) \
    "$pkg_dir"/completions/zsh/_*(N); do
    [[ -f "$file_item" ]] || continue
    count=$((count + 1))
  done

  [[ "$count" -gt 0 ]] || dazpm_die "invalid package: missing daz.toml or installable files"
}

dazpm_pkg_unlink_package() {
  local pkg_dir="$1"
  local file_item real_file

  for file_item in "$DAZPM_BIN_DIR"/*(N); do
    [[ -L "$file_item" ]] || continue
    real_file="${file_item:A}"
    [[ "$real_file" == "$pkg_dir"/* ]] && rm -f "$file_item"
  done

  for file_item in "$DAZPM_FUNCTIONS_DIR"/*(N); do
    [[ -L "$file_item" ]] || continue
    real_file="${file_item:A}"
    [[ "$real_file" == "$pkg_dir"/* ]] && rm -f "$file_item"
  done

  for file_item in "$DAZPM_PLUGINS_DIR"/*.zsh(N); do
    [[ -L "$file_item" ]] || continue
    real_file="${file_item:A}"
    [[ "$real_file" == "$pkg_dir"/* ]] && rm -f "$file_item"
  done

  for file_item in "$DAZPM_COMPLETIONS_DIR"/_*(N); do
    [[ -L "$file_item" ]] || continue
    real_file="${file_item:A}"
    [[ "$real_file" == "$pkg_dir"/* ]] && rm -f "$file_item"
  done
}

dazpm_pkg_link_kind() {
  local name="$1"
  local pkg_dir="$2"
  local kind="$3"
  local target_dir="$4"
  local prefix_name="${5:-0}"
  local file_item target_name target_file
  local linked_count=0
  local -a kind_files

  kind_files=("${(@f)$(dazpm_pkg_files_by_kind "$pkg_dir" "$kind")}")

  for file_item in "${kind_files[@]}"; do
    [[ -n "$file_item" ]] || continue
    [[ -f "$file_item" ]] || continue

    if [[ "$kind" == "bins" ]]; then
      chmod +x "$file_item" 2>/dev/null || true
    fi

    target_name="${file_item:t}"

    if [[ "$prefix_name" == "1" ]]; then
      target_name="${name}__${target_name}"
    fi

    target_file="$target_dir/$target_name"

    ln -sf "$file_item" "$target_file"
    linked_count=$((linked_count + 1))
  done

  print -r -- "$linked_count"
}

dazpm_pkg_link_package() {
  local name="$1"
  local pkg_dir="$2"
  local total_count=0
  local count_now

  dazpm_pkg_validate "$pkg_dir"

  mkdir -p \
    "$DAZPM_BIN_DIR" \
    "$DAZPM_FUNCTIONS_DIR" \
    "$DAZPM_PLUGINS_DIR" \
    "$DAZPM_COMPLETIONS_DIR"

  dazpm_pkg_unlink_package "$pkg_dir"

  count_now="$(dazpm_pkg_link_kind "$name" "$pkg_dir" "bins" "$DAZPM_BIN_DIR" 0)"
  total_count=$((total_count + count_now))

  count_now="$(dazpm_pkg_link_kind "$name" "$pkg_dir" "functions" "$DAZPM_FUNCTIONS_DIR" 0)"
  total_count=$((total_count + count_now))

  count_now="$(dazpm_pkg_link_kind "$name" "$pkg_dir" "plugins" "$DAZPM_PLUGINS_DIR" 1)"
  total_count=$((total_count + count_now))

  count_now="$(dazpm_pkg_link_kind "$name" "$pkg_dir" "completions" "$DAZPM_COMPLETIONS_DIR" 0)"
  total_count=$((total_count + count_now))

  [[ "$total_count" -gt 0 ]] || dazpm_die "package has no installable files"

  dazpm_log "linked $total_count file(s) from $name"
}
