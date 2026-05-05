# dazpm args parser
# Supports:
#   --flag
#   -f
#   --option value
#   -o value
#   --option=value
#   --
#
# Usage:
#   dazpm_args_parse "force|f,verbose|v" "output|o,type|t" "$@"
#   dazpm_args_has force
#   dazpm_args_get type "default"
#   dazpm_args_first

typeset -ga DAZPM_ARGS
typeset -gA DAZPM_OPTS
typeset -gA DAZPM_ARG_KIND
typeset -gA DAZPM_ARG_CANON
typeset -gi DAZPM_ARGS_CONSUMED

dazpm_args_reset() {
  DAZPM_ARGS=()
  DAZPM_OPTS=()
  DAZPM_ARG_KIND=()
  DAZPM_ARG_CANON=()
  DAZPM_ARGS_CONSUMED=0
}

dazpm_args_validate_name() {
  local name="$1"

  [[ -n "$name" ]] || return 1
  [[ "$name" != *[!A-Za-z0-9._-]* ]]
}

dazpm_args_register_group() {
  local kind="$1"
  local group="$2"
  local -a names
  local canonical alias_name

  [[ -n "$group" ]] || return 0

  names=("${(@s:|:)group}")
  canonical="${names[1]}"

  dazpm_args_validate_name "$canonical" || dazpm_die "invalid option name in parser spec: $canonical"

  for alias_name in "${names[@]}"; do
    [[ -n "$alias_name" ]] || continue
    dazpm_args_validate_name "$alias_name" || dazpm_die "invalid option alias in parser spec: $alias_name"

    DAZPM_ARG_KIND[$alias_name]="$kind"
    DAZPM_ARG_CANON[$alias_name]="$canonical"
  done
}

dazpm_args_register_spec() {
  local kind="$1"
  local spec="$2"
  local group
  local -a groups

  [[ -n "$spec" ]] || return 0

  groups=("${(@s:,:)spec}")

  for group in "${groups[@]}"; do
    [[ -n "$group" ]] || continue
    dazpm_args_register_group "$kind" "$group"
  done
}

dazpm_args_kind_of() {
  local key="$1"

  [[ -n "${DAZPM_ARG_KIND[$key]+x}" ]] || return 1
  print -r -- "${DAZPM_ARG_KIND[$key]}"
}

dazpm_args_canon_of() {
  local key="$1"

  [[ -n "${DAZPM_ARG_CANON[$key]+x}" ]] || return 1
  print -r -- "${DAZPM_ARG_CANON[$key]}"
}

dazpm_args_set_bool() {
  local key="$1"
  local canonical

  canonical="$(dazpm_args_canon_of "$key")" || dazpm_die "unknown option: $key"
  DAZPM_OPTS[$canonical]="1"
}

dazpm_args_set_value() {
  local key="$1"
  local value="$2"
  local canonical

  canonical="$(dazpm_args_canon_of "$key")" || dazpm_die "unknown option: $key"
  DAZPM_OPTS[$canonical]="$value"
}

dazpm_args_parse_long() {
  local arg="$1"
  local next_value="${2:-}"
  local key value kind

  DAZPM_ARGS_CONSUMED=0

  if [[ "$arg" == *=* ]]; then
    key="${arg%%=*}"
    value="${arg#*=}"
    key="${key#--}"

    kind="$(dazpm_args_kind_of "$key")" || dazpm_die "unknown option: --$key"

    case "$kind" in
      bool)
        dazpm_die "option does not take a value: --$key"
        ;;
      value)
        dazpm_args_set_value "$key" "$value"
        ;;
    esac

    return 0
  fi

  key="${arg#--}"
  kind="$(dazpm_args_kind_of "$key")" || dazpm_die "unknown option: --$key"

  case "$kind" in
    bool)
      dazpm_args_set_bool "$key"
      ;;
    value)
      [[ "$#" -ge 2 ]] || dazpm_die "option requires a value: --$key"
      dazpm_args_set_value "$key" "$next_value"
      DAZPM_ARGS_CONSUMED=1
      ;;
  esac

  return 0
}

dazpm_args_parse_short() {
  local arg="$1"
  local next_value="${2:-}"
  local chunk key kind
  local i char

  DAZPM_ARGS_CONSUMED=0
  chunk="${arg#-}"

  if [[ "${#chunk}" -eq 1 ]]; then
    key="$chunk"
    kind="$(dazpm_args_kind_of "$key")" || dazpm_die "unknown option: -$key"

    case "$kind" in
      bool)
        dazpm_args_set_bool "$key"
        ;;
      value)
        [[ "$#" -ge 2 ]] || dazpm_die "option requires a value: -$key"
        dazpm_args_set_value "$key" "$next_value"
        DAZPM_ARGS_CONSUMED=1
        ;;
    esac

    return 0
  fi

  for (( i = 1; i <= ${#chunk}; i++ )); do
    char="${chunk[i]}"
    kind="$(dazpm_args_kind_of "$char")" || dazpm_die "unknown option: -$char"

    [[ "$kind" == "bool" ]] || dazpm_die "cannot combine value option in short group: -$char"

    dazpm_args_set_bool "$char"
  done

  return 0
}

dazpm_args_parse() {
  local bool_spec="$1"
  local value_spec="$2"
  shift 2

  local arg
  local end_options=0

  dazpm_args_reset
  dazpm_args_register_spec "bool" "$bool_spec"
  dazpm_args_register_spec "value" "$value_spec"

  while [[ "$#" -gt 0 ]]; do
    arg="$1"
    shift

    if [[ "$end_options" -eq 1 ]]; then
      DAZPM_ARGS+=("$arg")
      continue
    fi

    case "$arg" in
      --)
        end_options=1
        ;;

      --*)
        dazpm_args_parse_long "$arg" "$@"

        if [[ "$DAZPM_ARGS_CONSUMED" -eq 1 ]]; then
          shift
        fi
        ;;

      -?*)
        dazpm_args_parse_short "$arg" "$@"

        if [[ "$DAZPM_ARGS_CONSUMED" -eq 1 ]]; then
          shift
        fi
        ;;

      *)
        DAZPM_ARGS+=("$arg")
        ;;
    esac
  done
}

dazpm_args_has() {
  local key="$1"

  [[ -n "${DAZPM_OPTS[$key]+x}" ]]
}

dazpm_args_get() {
  local key="$1"
  local default="${2:-}"

  if [[ -n "${DAZPM_OPTS[$key]+x}" ]]; then
    print -r -- "${DAZPM_OPTS[$key]}"
  else
    print -r -- "$default"
  fi
}

dazpm_args_first() {
  local default="${1:-}"

  if [[ "${#DAZPM_ARGS[@]}" -gt 0 ]]; then
    print -r -- "${DAZPM_ARGS[1]}"
  else
    print -r -- "$default"
  fi
}
