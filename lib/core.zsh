dazpm_usage() {
  cat <<'EOF'
dazpm - shell package manager for zsh

Usage:
  dazpm help
  dazpm init
  dazpm doctor
  dazpm rebuild
  dazpm list
  dazpm install <source>
  dazpm remove <name>
  dazpm uninstall <name>
  dazpm link <path> [name]
  dazpm path <name>
  dazpm commands <name>

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
}
