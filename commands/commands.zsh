source "$DAZPM_ROOT/lib/package.zsh"
source "$DAZPM_ROOT/lib/args.zsh"

dazpm_cmd_commands() {
  dazpm_args_parse "path|p" "" "$@"

  local input
  input="$(dazpm_args_first)"

  [[ -n "$input" ]] || dazpm_die "usage: dazpm commands <name> | dazpm commands --path <dir>"

  local name pkg_dir

  if dazpm_args_has path; then
    pkg_dir="${input:A}"
    [[ -d "$pkg_dir" ]] || dazpm_die "directory not found: $pkg_dir"
    name="${pkg_dir:t}"
    dazpm_warn "inspecting local package, not installed"
  else
    name="$input"
    pkg_dir="$DAZPM_PACKAGES_DIR/$name"
    [[ -e "$pkg_dir" ]] || dazpm_die "package not installed: $name"
    pkg_dir="${pkg_dir:A}"
  fi

  local found=0
  local file_item
  local -a bin_files function_files

  dazpm_ui_header "Commands in $name"

  bin_files=("${(@f)$(dazpm_pkg_files_by_kind "$pkg_dir" "bins")}")
  function_files=("${(@f)$(dazpm_pkg_files_by_kind "$pkg_dir" "functions")}")

  for file_item in "${bin_files[@]}"; do
    [[ -n "$file_item" ]] || continue
    [[ -f "$file_item" ]] || continue
    found=1
    dazpm_ui_item "${file_item:t}"
  done

  for file_item in "${function_files[@]}"; do
    [[ -n "$file_item" ]] || continue
    [[ -f "$file_item" ]] || continue
    found=1
    dazpm_ui_item "${file_item:t}"
  done

  if [[ "$found" -eq 0 ]]; then
    dazpm_warn "no commands found"
  fi
}
