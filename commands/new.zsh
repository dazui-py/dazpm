dazpm_new_safe_function_name() {
  local name="$1"
  local safe="$name"

  safe="${safe//-/_}"
  safe="${safe//./_}"

  print -r -- "$safe"
}

dazpm_cmd_new() {
  local name="${1:-}"

  [[ -n "$name" ]] || dazpm_die "usage: dazpm new <name>"

  if [[ "$name" == *[!A-Za-z0-9._-]* ]]; then
    dazpm_die "unsafe package name: $name"
  fi

  local pkg_dir="$PWD/$name"
  local plugin_file="plugins/$name.zsh"
  local fn_name

  fn_name="$(dazpm_new_safe_function_name "$name")"

  [[ ! -e "$pkg_dir" ]] || dazpm_die "directory already exists: $pkg_dir"

  dazpm_ui_header "Creating package $name"

  mkdir -p \
    "$pkg_dir/bin" \
    "$pkg_dir/functions" \
    "$pkg_dir/plugins" \
    "$pkg_dir/completions/zsh"

  cat > "$pkg_dir/daz.toml" <<EOF_TOML
name = "$name"
version = "0.1.0"
description = ""
author = ""
license = ""

[shell]
supports = ["zsh"]

[install]
bins = []
plugins = ["$plugin_file"]
functions = []
completions = []

[meta]
tags = ["zsh"]
EOF_TOML

  cat > "$pkg_dir/$plugin_file" <<EOF_PLUGIN
# $name plugin
# Add shell functions, aliases, or hooks here.

${fn_name}_hello() {
  echo "hello from $name"
}
EOF_PLUGIN

  cat > "$pkg_dir/README.md" <<EOF_README
# $name

A dazpm package.

## Install

\`\`\`sh
dazpm install user/$name
\`\`\`

For local development:

\`\`\`sh
dazpm link .
source ~/.local/share/dazpm/init.zsh
${fn_name}_hello
\`\`\`
EOF_README

  dazpm_ui_kv "path" "$pkg_dir"
  dazpm_ui_kv "plugin" "$plugin_file"
  dazpm_ui_kv "function" "${fn_name}_hello"
  dazpm_log "created package skeleton"
  dazpm_info "run: dazpm validate $name"
}
