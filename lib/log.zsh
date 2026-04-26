dazpm_log() {
  print -r -- "dazpm: $*"
}

dazpm_warn() {
  print -r -- "dazpm warning: $*" >&2
}

dazpm_die() {
  print -r -- "dazpm error: $*" >&2
  exit 1
}
