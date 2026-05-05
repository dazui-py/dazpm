dazpm_record_dir() {
  local name="$1"
  print -r -- "$DAZPM_RECORDS_DIR/$name"
}

dazpm_record_write() {
  local name="$1"
  local type="$2"
  local source="$3"
  local url="$4"
  local ref="$5"
  local pkg_path="$6"

  local dir
  dir="$(dazpm_record_dir "$name")"

  mkdir -p "$dir"

  print -r -- "$type" > "$dir/type"
  print -r -- "$source" > "$dir/source"
  print -r -- "$url" > "$dir/url"
  print -r -- "$ref" > "$dir/ref"
  print -r -- "$pkg_path" > "$dir/path"
}

dazpm_record_remove() {
  local name="$1"
  rm -rf "$DAZPM_RECORDS_DIR/$name"
}

dazpm_record_get() {
  local name="$1"
  local key="$2"
  local file="$DAZPM_RECORDS_DIR/$name/$key"

  [[ -f "$file" ]] || return 1
  cat "$file"
}

dazpm_record_exists() {
  local name="$1"
  [[ -d "$DAZPM_RECORDS_DIR/$name" ]]
}
