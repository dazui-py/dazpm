dazpm_pkg_validate() {
  local pkg_dir="$1"

  [[ -d "$pkg_dir" ]] || dazpm_die "package directory not found: $pkg_dir"

  if [[ ! -d "$pkg_dir/bin" \
     && ! -d "$pkg_dir/functions" \
     && ! -d "$pkg_dir/plugins" \
     && ! -d "$pkg_dir/completions/zsh" ]]; then
    dazpm_die "invalid package: missing bin/, functions/, plugins/, or completions/zsh/"
  fi
}

dazpm_pkg_unlink_package() {
  local pkg_dir="$1"
  local f real

  for f in "$DAZPM_BIN_DIR"/*(N); do
    [[ -L "$f" ]] || continue
    real="${f:A}"
    [[ "$real" == "$pkg_dir"/* ]] && rm -f "$f"
  done

  for f in "$DAZPM_FUNCTIONS_DIR"/*(N); do
    [[ -L "$f" ]] || continue
    real="${f:A}"
    [[ "$real" == "$pkg_dir"/* ]] && rm -f "$f"
  done

  for f in "$DAZPM_PLUGINS_DIR"/*.zsh(N); do
    [[ -L "$f" ]] || continue
    real="${f:A}"
    [[ "$real" == "$pkg_dir"/* ]] && rm -f "$f"
  done

  for f in "$DAZPM_COMPLETIONS_DIR"/_*(N); do
    [[ -L "$f" ]] || continue
    real="${f:A}"
    [[ "$real" == "$pkg_dir"/* ]] && rm -f "$f"
  done
}

dazpm_pkg_link_package() {
  local name="$1"
  local pkg_dir="$2"
  local count=0
  local f target

  dazpm_pkg_validate "$pkg_dir"

  mkdir -p \
    "$DAZPM_BIN_DIR" \
    "$DAZPM_FUNCTIONS_DIR" \
    "$DAZPM_PLUGINS_DIR" \
    "$DAZPM_COMPLETIONS_DIR"

  dazpm_pkg_unlink_package "$pkg_dir"

  for f in "$pkg_dir"/bin/*(N); do
    [[ -f "$f" ]] || continue
    chmod +x "$f" 2>/dev/null || true
    target="$DAZPM_BIN_DIR/${f:t}"
    ln -sf "$f" "$target"
    count=$((count + 1))
  done

  for f in "$pkg_dir"/functions/*(N); do
    [[ -f "$f" ]] || continue
    target="$DAZPM_FUNCTIONS_DIR/${f:t}"
    ln -sf "$f" "$target"
    count=$((count + 1))
  done

  for f in "$pkg_dir"/plugins/*.zsh(N); do
    [[ -f "$f" ]] || continue
    target="$DAZPM_PLUGINS_DIR/${name}__${f:t}"
    ln -sf "$f" "$target"
    count=$((count + 1))
  done

  for f in "$pkg_dir"/completions/zsh/_*(N); do
    [[ -f "$f" ]] || continue
    target="$DAZPM_COMPLETIONS_DIR/${f:t}"
    ln -sf "$f" "$target"
    count=$((count + 1))
  done

  [[ "$count" -gt 0 ]] || dazpm_die "package has no installable files"

  dazpm_log "linked $count file(s) from $name"
}
