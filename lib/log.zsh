dazpm_log() {
  dazpm_ui_ok "$*"
}

dazpm_info() {
  dazpm_ui_info "$*"
}

dazpm_warn() {
  dazpm_ui_warn "$*"
}

dazpm_die() {
  dazpm_ui_error "$*"
  exit 1
}
