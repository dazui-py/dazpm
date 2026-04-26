dazpm_usage() {
  dazpm_ui_title "dazpm" "shell package manager for zsh"
  dazpm_ui_blank

  dazpm_ui_section "Usage"
  dazpm_ui_command "dazpm <command> [args]"
  dazpm_ui_blank

  dazpm_ui_section "Core"
  dazpm_ui_command "dazpm help" "show this help message"
  dazpm_ui_command "dazpm init" "initialize dazpm for zsh"
  dazpm_ui_command "dazpm doctor" "check your environment"
  dazpm_ui_command "dazpm rebuild" "rebuild the zsh loader"
  dazpm_ui_command "dazpm repair" "repair missing package records"
  dazpm_ui_blank

  dazpm_ui_section "Packages"
  dazpm_ui_command "dazpm install <source>" "install a remote package"
  dazpm_ui_command "dazpm remove <name>" "remove an installed package"
  dazpm_ui_command "dazpm uninstall <name>" "alias for remove"
  dazpm_ui_command "dazpm update [name]" "update one package or all packages"
  dazpm_ui_command "dazpm update --git" "update only git packages"
  dazpm_ui_command "dazpm update --links" "refresh only linked local packages"
  dazpm_ui_command "dazpm link <path> [name]" "link a local package"
  dazpm_ui_command "dazpm new <name>" "create a new package skeleton"
  dazpm_ui_command "dazpm validate [path]" "validate a package directory"
  dazpm_ui_blank

  dazpm_ui_section "Inspect"
  dazpm_ui_command "dazpm list [-v]" "list installed packages"
  dazpm_ui_command "dazpm info <name>" "show package metadata"
  dazpm_ui_command "dazpm files <name>" "show package files"
  dazpm_ui_command "dazpm path <name>" "print package path"
  dazpm_ui_command "dazpm commands <name>" "show commands from a package"
  dazpm_ui_blank

  dazpm_ui_section "Sources"
  dazpm_ui_example "user/repo"
  dazpm_ui_example "user/repo@ref"
  dazpm_ui_example "github:user/repo"
  dazpm_ui_example "https://github.com/user/repo.git"
  dazpm_ui_blank

  dazpm_ui_section "Package layout"
  dazpm_ui_example "daz.toml"
  dazpm_ui_example "bin/"
  dazpm_ui_example "functions/"
  dazpm_ui_example "plugins/"
  dazpm_ui_example "completions/zsh/"

  dazpm_ui_blank
  dazpm_ui_section "Manifest"
  dazpm_ui_command "daz.toml" "optional package metadata and install manifest"
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
