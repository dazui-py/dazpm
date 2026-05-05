dazpm_usage() {
  dazpm_ui_title "dazpm" "shell package manager for zsh"
  dazpm_ui_blank

  dazpm_ui_section "Usage"
  dazpm_ui_command "dazpm <command> [args] [options]"
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
  dazpm_ui_command "dazpm install <source> --name <name>" "install using a custom package name"
  dazpm_ui_command "dazpm install <source> --ref <ref>" "install a branch, tag, or ref"
  dazpm_ui_command "dazpm install <source> --force" "overwrite existing package"
  dazpm_ui_blank

  dazpm_ui_command "dazpm link <path> [name]" "link a local package"
  dazpm_ui_command "dazpm link <path> --name <name>" "link using a custom package name"
  dazpm_ui_blank

  dazpm_ui_command "dazpm update [name]" "update one package or all packages"
  dazpm_ui_command "dazpm update --git" "update only git packages"
  dazpm_ui_command "dazpm update --links" "refresh only linked local packages"
  dazpm_ui_command "dazpm update --local" "alias for --links"
  dazpm_ui_blank

  dazpm_ui_command "dazpm remove <name>" "remove an installed package"
  dazpm_ui_command "dazpm remove <name> --dry-run" "show what would be removed"
  dazpm_ui_command "dazpm uninstall <name>" "alias for remove"
  dazpm_ui_blank

  dazpm_ui_command "dazpm new <name>" "create a new package skeleton"
  dazpm_ui_command "dazpm new <name> --author <name>" "set package author"
  dazpm_ui_command "dazpm new <name> --license <name>" "set package license"
  dazpm_ui_command "dazpm new <name> --desc <text>" "set package description"
  dazpm_ui_command "dazpm new <name> --version <ver>" "set package version"
  dazpm_ui_command "dazpm new <name> --no-readme" "skip README.md creation"
  dazpm_ui_blank

  dazpm_ui_section "Inspect"
  dazpm_ui_command "dazpm list" "list installed packages"
  dazpm_ui_command "dazpm list -v, --verbose" "show package type and source"
  dazpm_ui_command "dazpm list --plain" "print only package names"
  dazpm_ui_blank

  dazpm_ui_command "dazpm info <name>" "show installed package metadata"
  dazpm_ui_command "dazpm info --path <dir>" "inspect local package without installing"
  dazpm_ui_blank

  dazpm_ui_command "dazpm files <name>" "show installed package files"
  dazpm_ui_command "dazpm files --path <dir>" "show local package files without installing"
  dazpm_ui_blank

  dazpm_ui_command "dazpm commands <name>" "show commands from installed package"
  dazpm_ui_command "dazpm commands --path <dir>" "show commands from local package"
  dazpm_ui_blank

  dazpm_ui_command "dazpm path <name>" "print installed package path"
  dazpm_ui_command "dazpm path --path <dir>" "resolve a local package path"
  dazpm_ui_blank

  dazpm_ui_command "dazpm validate [path]" "validate a package directory"
  dazpm_ui_command "dazpm validate --path <dir>" "validate a package directory"
  dazpm_ui_command "dazpm validate --quiet" "validate with no success output"
  dazpm_ui_blank

  dazpm_ui_section "Common options"
  dazpm_ui_command "-p, --path <dir>" "use a local package directory"
  dazpm_ui_command "-n, --name <name>" "set custom package name"
  dazpm_ui_command "-r, --ref <ref>" "set git branch, tag, or ref"
  dazpm_ui_command "-f, --force" "force overwrite when supported"
  dazpm_ui_command "-q, --quiet" "suppress success output"
  dazpm_ui_command "--plain" "machine-friendly plain output"
  dazpm_ui_command "--dry-run" "preview without changing anything"
  dazpm_ui_command "--" "stop option parsing"
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
