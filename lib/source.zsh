dazpm_source_parse() {
  local raw="$1"
  local base="$raw"
  local ref=""

  [[ -n "$raw" ]] || dazpm_die "missing source"

  if [[ "$raw" != git@* && "$raw" == *@* ]]; then
    ref="${raw##*@}"
    base="${raw%@*}"
  fi

  local url=""
  local name=""

  case "$base" in
    github:*)
      local repo="${base#github:}"
      [[ "$repo" == */* ]] || dazpm_die "invalid github source: $raw"
      url="https://github.com/$repo.git"
      name="${repo:t}"
      ;;

    https://*|http://*|git@*)
      url="$base"
      name="${base:t}"
      name="${name%.git}"
      ;;

    */*)
      url="https://github.com/$base.git"
      name="${base:t}"
      ;;

    *)
      dazpm_die "invalid source. Use user/repo, github:user/repo, or git URL"
      ;;
  esac

  [[ -n "$name" ]] || dazpm_die "could not detect package name"

  if [[ "$name" == *[!A-Za-z0-9._-]* ]]; then
    dazpm_die "unsafe package name: $name"
  fi

  export DAZPM_SOURCE_URL="$url"
  export DAZPM_SOURCE_NAME="$name"
  export DAZPM_SOURCE_REF="$ref"
}
