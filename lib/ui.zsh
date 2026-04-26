# dazpm UI helpers

dazpm_ui_color_enabled() {
  [[ -t 1 ]] || return 1
  [[ -z "${NO_COLOR:-}" ]] || return 1
  [[ "${DAZPM_COLOR:-auto}" != "never" ]] || return 1
  return 0
}

dazpm_ui_width() {
  local width="${COLUMNS:-}"

  if [[ -z "$width" || "$width" -le 0 ]]; then
    width="$(tput cols 2>/dev/null || print 80)"
  fi

  [[ "$width" -gt 0 ]] || width=80
  print -r -- "$width"
}

dazpm_ui_is_narrow() {
  local width
  width="$(dazpm_ui_width)"

  [[ "$width" -lt 70 ]]
}

dazpm_ui_trunc() {
  local text="$1"
  local max="$2"

  [[ "$max" -lt 5 ]] && max=5

  if [[ "${#text}" -le "$max" ]]; then
    print -r -- "$text"
    return 0
  fi

  local keep=$(( max - 1 ))
  print -r -- "${text[1,$keep]}…"
}

dazpm_ui_trunc_mid() {
  local text="$1"
  local max="$2"

  [[ "$max" -lt 8 ]] && max=8

  if [[ "${#text}" -le "$max" ]]; then
    print -r -- "$text"
    return 0
  fi

  local left=$(( (max - 1) / 2 ))
  local right=$(( max - left - 1 ))

  print -r -- "${text[1,$left]}…${text[-$right,-1]}"
}

if dazpm_ui_color_enabled; then
  DAZPM_RESET=$'%f%k%b'
  DAZPM_BOLD=$'%B'
  DAZPM_DIM=$'%F{8}'

  case "${DAZPM_ACCENT:-cyan}" in
    purple|magenta)
      DAZPM_ACCENT=$'%F{5}'
      ;;
    blue)
      DAZPM_ACCENT=$'%F{4}'
      ;;
    green)
      DAZPM_ACCENT=$'%F{2}'
      ;;
    yellow)
      DAZPM_ACCENT=$'%F{3}'
      ;;
    red)
      DAZPM_ACCENT=$'%F{1}'
      ;;
    cyan|*)
      DAZPM_ACCENT=$'%F{6}'
      ;;
  esac

  DAZPM_RED=$'%F{1}'
  DAZPM_GREEN=$'%F{2}'
  DAZPM_YELLOW=$'%F{3}'
  DAZPM_BLUE=$'%F{4}'
  DAZPM_MAGENTA=$'%F{5}'
  DAZPM_CYAN=$'%F{6}'
  DAZPM_WHITE=$'%F{7}'
else
  DAZPM_RESET=''
  DAZPM_BOLD=''
  DAZPM_DIM=''
  DAZPM_ACCENT=''
  DAZPM_RED=''
  DAZPM_GREEN=''
  DAZPM_YELLOW=''
  DAZPM_BLUE=''
  DAZPM_MAGENTA=''
  DAZPM_CYAN=''
  DAZPM_WHITE=''
fi

dazpm_ui_print() {
  print -P -- "$*"
}

dazpm_ui_header() {
  dazpm_ui_print "${DAZPM_BOLD}${DAZPM_ACCENT}==>${DAZPM_RESET} ${DAZPM_BOLD}$*${DAZPM_RESET}"
}

dazpm_ui_section() {
  dazpm_ui_print "${DAZPM_BOLD}${DAZPM_ACCENT}$*${DAZPM_RESET}"
}

dazpm_ui_ok() {
  dazpm_ui_print "${DAZPM_GREEN}✓${DAZPM_RESET} $*"
}

dazpm_ui_info() {
  dazpm_ui_print "${DAZPM_BLUE}i${DAZPM_RESET} $*"
}

dazpm_ui_warn() {
  dazpm_ui_print "${DAZPM_YELLOW}!${DAZPM_RESET} $*" >&2
}

dazpm_ui_error() {
  dazpm_ui_print "${DAZPM_RED}x${DAZPM_RESET} $*" >&2
}

dazpm_ui_kv() {
  local key="$1"
  local value="$2"
  local width max value_out

  width="$(dazpm_ui_width)"
  max=$(( width - 14 ))

  [[ "$max" -lt 20 ]] && max=20

  value_out="$(dazpm_ui_trunc_mid "$value" "$max")"

  printf "  %-10s %s\n" "$key" "$value_out"
}

dazpm_ui_card_kv() {
  local key="$1"
  local value="$2"

  dazpm_ui_print "  ${DAZPM_DIM}${key}:${DAZPM_RESET} $value"
}

dazpm_ui_item() {
  dazpm_ui_print "  ${DAZPM_ACCENT}•${DAZPM_RESET} $*"
}

dazpm_ui_blank() {
  print
}

dazpm_ui_should_pad() {
  [[ -t 1 ]] || return 1
  [[ "${DAZPM_COMPACT:-0}" != "1" ]] || return 1
  [[ "${DAZPM_SPACING:-normal}" != "none" ]] || return 1
  return 0
}

dazpm_ui_after_command() {
  dazpm_ui_should_pad || return 0
  print
}

dazpm_ui_title() {
  local title="$1"
  local subtitle="${2:-}"

  if [[ -n "$subtitle" ]]; then
    dazpm_ui_print "${DAZPM_BOLD}${DAZPM_ACCENT}${title}${DAZPM_RESET} ${DAZPM_DIM}${subtitle}${DAZPM_RESET}"
  else
    dazpm_ui_print "${DAZPM_BOLD}${DAZPM_ACCENT}${title}${DAZPM_RESET}"
  fi
}

dazpm_ui_subtitle() {
  dazpm_ui_print "${DAZPM_DIM}$*${DAZPM_RESET}"
}

dazpm_ui_command() {
  local cmd="$1"
  local desc="${2:-}"

  if [[ -n "$desc" ]]; then
    dazpm_ui_print "  ${DAZPM_GREEN}${cmd}${DAZPM_RESET} ${DAZPM_DIM}${desc}${DAZPM_RESET}"
  else
    dazpm_ui_print "  ${DAZPM_GREEN}${cmd}${DAZPM_RESET}"
  fi
}

dazpm_ui_example() {
  dazpm_ui_print "  ${DAZPM_MAGENTA}$*${DAZPM_RESET}"
}

dazpm_ui_label() {
  dazpm_ui_print "${DAZPM_BOLD}${DAZPM_ACCENT}$*${DAZPM_RESET}"
}

dazpm_ui_raw_or_color() {
  local value="$1"

  if [[ -t 1 ]]; then
    dazpm_ui_print "${DAZPM_ACCENT}${value}${DAZPM_RESET}"
  else
    print -r -- "$value"
  fi
}
