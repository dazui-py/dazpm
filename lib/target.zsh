# Resolve package target for commands like info/files/commands/validate.
#
# Supports:
#   dazpm info package-name
#   dazpm info --path ./package
#   dazpm info -p ./package

typeset -g DAZPM_TARGET_NAME=""
typeset -g DAZPM_TARGET_DIR=""
typeset -g DAZPM_TARGET_KIND=""

dazpm_target_reset() {
  DAZPM_TARGET_NAME=""
  DAZPM_TARGET_DIR=""
  DAZPM_TARGET_KIND=""
}

dazpm_target_resolve() {
  local value="$1"
  local as_path="${2:-0}"

  dazpm_target_reset

  [[ -n "$value" ]] || dazpm_die "missing package name or path"

  if [[ "$as_path" == "1" ]]; then
    DAZPM_TARGET_DIR="${value:A}"

    [[ -d "$DAZPM_TARGET_DIR" ]] || dazpm_die "directory not found: $DAZPM_TARGET_DIR"

    DAZPM_TARGET_NAME="${DAZPM_TARGET_DIR:t}"
    DAZPM_TARGET_KIND="path"

    dazpm_warn "inspecting local package, not installed"
    return 0
  fi

  DAZPM_TARGET_NAME="$value"
  DAZPM_TARGET_DIR="$DAZPM_PACKAGES_DIR/$value"
  DAZPM_TARGET_KIND="installed"

  [[ -e "$DAZPM_TARGET_DIR" ]] || dazpm_die "package not installed: $value"

  DAZPM_TARGET_DIR="${DAZPM_TARGET_DIR:A}"
}
