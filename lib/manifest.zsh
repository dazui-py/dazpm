# daz.toml v0 parser
# This is NOT a full TOML parser.
# Supported:
#   key = "value"
#   key = ["a", "b"]
#   [section]

dazpm_manifest_file() {
  local pkg_dir="$1"
  print -r -- "$pkg_dir/daz.toml"
}

dazpm_manifest_exists() {
  local pkg_dir="$1"
  [[ -f "$(dazpm_manifest_file "$pkg_dir")" ]]
}

dazpm_manifest_trim() {
  print -r -- "$*" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

dazpm_manifest_raw() {
  local pkg_dir="$1"
  local section_name="$2"
  local key_name="$3"
  local manifest_file

  manifest_file="$(dazpm_manifest_file "$pkg_dir")"

  [[ -f "$manifest_file" ]] || return 1

  awk -v want_section="$section_name" -v want_key="$key_name" '
    function trim(s) {
      gsub(/^[ \t]+|[ \t]+$/, "", s)
      return s
    }

    BEGIN {
      current = ""
    }

    {
      sub(/\r$/, "")
      line = $0

      # simple comments only; not valid for # inside strings
      sub(/[ \t]*#.*/, "", line)

      line = trim(line)
      if (line == "") next

      if (line ~ /^\[[A-Za-z0-9_.-]+\]$/) {
        current = line
        gsub(/^\[|\]$/, "", current)
        next
      }

      idx = index(line, "=")
      if (idx == 0) next

      k = trim(substr(line, 1, idx - 1))
      v = trim(substr(line, idx + 1))

      if (current == want_section && k == want_key) {
        print v
        exit 0
      }
    }
  ' "$manifest_file"
}

dazpm_manifest_unquote() {
  local value="$1"

  value="$(dazpm_manifest_trim "$value")"

  if [[ "$value" == \"*\" ]]; then
    value="${value#\"}"
    value="${value%\"}"
  elif [[ "$value" == \'*\' ]]; then
    value="${value#\'}"
    value="${value%\'}"
  fi

  print -r -- "$value"
}

dazpm_manifest_get_value() {
  local pkg_dir="$1"
  local section_name="$2"
  local key_name="$3"
  local raw_value

  raw_value="$(dazpm_manifest_raw "$pkg_dir" "$section_name" "$key_name" 2>/dev/null)" || return 1
  [[ -n "$raw_value" ]] || return 1

  dazpm_manifest_unquote "$raw_value"
}

dazpm_manifest_get_array() {
  local pkg_dir="$1"
  local section_name="$2"
  local key_name="$3"
  local raw_value body item
  local -a parts

  raw_value="$(dazpm_manifest_raw "$pkg_dir" "$section_name" "$key_name" 2>/dev/null)" || return 1
  raw_value="$(dazpm_manifest_trim "$raw_value")"

  [[ "$raw_value" == \[*\] ]] || dazpm_die "invalid array in daz.toml: [$section_name].$key_name"

  body="${raw_value#\[}"
  body="${body%\]}"

  [[ -n "$(dazpm_manifest_trim "$body")" ]] || return 0

  parts=("${(@s:,:)body}")

  for item in "${parts[@]}"; do
    item="$(dazpm_manifest_trim "$item")"
    item="$(dazpm_manifest_unquote "$item")"

    [[ -n "$item" ]] || continue
    print -r -- "$item"
  done
}

dazpm_manifest_array_contains() {
  local pkg_dir="$1"
  local section_name="$2"
  local key_name="$3"
  local wanted="$4"
  local item

  while IFS= read -r item; do
    [[ "$item" == "$wanted" ]] && return 0
  done < <(dazpm_manifest_get_array "$pkg_dir" "$section_name" "$key_name" 2>/dev/null)

  return 1
}

dazpm_manifest_has_install() {
  local pkg_dir="$1"

  dazpm_manifest_raw "$pkg_dir" "install" "bins" >/dev/null 2>&1 && return 0
  dazpm_manifest_raw "$pkg_dir" "install" "plugins" >/dev/null 2>&1 && return 0
  dazpm_manifest_raw "$pkg_dir" "install" "functions" >/dev/null 2>&1 && return 0
  dazpm_manifest_raw "$pkg_dir" "install" "completions" >/dev/null 2>&1 && return 0

  return 1
}

dazpm_manifest_safe_relpath() {
  local rel_file="$1"

  [[ -n "$rel_file" ]] || return 1
  [[ "$rel_file" != /* ]] || return 1
  [[ "$rel_file" != *".."* ]] || return 1

  return 0
}

dazpm_manifest_install_files() {
  local pkg_dir="$1"
  local kind="$2"
  local rel_file abs_file

  while IFS= read -r rel_file; do
    dazpm_manifest_safe_relpath "$rel_file" || dazpm_die "unsafe path in daz.toml: $rel_file"

    abs_file="$pkg_dir/$rel_file"

    [[ -f "$abs_file" ]] || dazpm_die "file declared in daz.toml does not exist: $rel_file"

    print -r -- "$abs_file"
  done < <(dazpm_manifest_get_array "$pkg_dir" "install" "$kind" 2>/dev/null)
}

dazpm_manifest_validate() {
  local pkg_dir="$1"
  local pkg_name pkg_version

  dazpm_manifest_exists "$pkg_dir" || return 0

  pkg_name="$(dazpm_manifest_get_value "$pkg_dir" "" "name" 2>/dev/null || true)"
  pkg_version="$(dazpm_manifest_get_value "$pkg_dir" "" "version" 2>/dev/null || true)"

  [[ -n "$pkg_name" ]] || dazpm_die "daz.toml missing required field: name"
  [[ -n "$pkg_version" ]] || dazpm_die "daz.toml missing required field: version"

  if [[ "$pkg_name" == *[!A-Za-z0-9._-]* ]]; then
    dazpm_die "unsafe package name in daz.toml: $pkg_name"
  fi

  if dazpm_manifest_raw "$pkg_dir" "shell" "supports" >/dev/null 2>&1; then
    dazpm_manifest_array_contains "$pkg_dir" "shell" "supports" "zsh" \
      || dazpm_die "package does not support zsh"
  fi

  dazpm_manifest_has_install "$pkg_dir" \
    || dazpm_die "daz.toml missing [install] entries"

  dazpm_manifest_install_files "$pkg_dir" "bins" >/dev/null
  dazpm_manifest_install_files "$pkg_dir" "plugins" >/dev/null
  dazpm_manifest_install_files "$pkg_dir" "functions" >/dev/null
  dazpm_manifest_install_files "$pkg_dir" "completions" >/dev/null
}
