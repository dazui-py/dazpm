dazpm_usage() {
  cat <<'EOF'
dazpm - shell package manager for zsh

Usage:
  dazpm help
  dazpm init
  dazpm doctor
  dazpm rebuild

Packages:
  dazpm install <source>
  dazpm remove <name>
  dazpm uninstall <name>
  dazpm update [name]
  dazpm link <path> [name]

Inspect:
  dazpm list [-v]
  dazpm path <name>
  dazpm commands <name>
  dazpm info <name>
  dazpm files <name>

Sources:
  user/repo
  user/repo@ref
  github:user/repo
  https://github.com/user/repo.git

Package layout:
  bin/
  functions/
  plugins/
  completions/zsh/
EOF
}

dazpm_main() {
  local cmd="${1:-help}"
  shift || true

  local command_file="$DAZPM_ROOT/commands/$cmd.zsh"

  if [[ "$cmd" == "-h" || "$cmd" == "--help" ]]; then
    dazpm_usage
    dazpm_ui_after_command
    return 0
  fi

  if [[ ! -f "$command_file" ]]; then
    dazpm_die "unknown command: $cmd"
  fi

  source "$command_file"

  local fn="dazpm_cmd_$cmd"

  if ! whence -w "$fn" >/dev/null 2>&1; then
    dazpm_die "command file exists but function is missing: $fn"
  fi

  "$fn" "$@"
  local exit_code=$?

  if [[ "$exit_code" -eq 0 ]]; then
    dazpm_ui_after_command
  fi

  return "$exit_code"
}
