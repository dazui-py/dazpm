dazpm_git_clone() {
  local url="$1"
  local ref="$2"
  local dest="$3"

  command -v git >/dev/null 2>&1 || dazpm_die "git is required"

  if [[ -n "$ref" ]]; then
    git clone --depth 1 --branch "$ref" "$url" "$dest"
  else
    git clone --depth 1 "$url" "$dest"
  fi
}
