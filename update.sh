#!/usr/bin/env sh
set -eu

APP_NAME="dazpm"
REPO_URL="${DAZPM_REPO_URL:-https://github.com/dazui-py/dazpm.git}"
BRANCH="${DAZPM_BRANCH:-main}"

: "${PREFIX:?PREFIX is not set. Run this inside Termux or export PREFIX first.}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command not found: $1" >&2
    exit 1
  }
}

info() {
  printf '%s\n' "[*] $*"
}

ok() {
  printf '%s\n' "[+] $*"
}

need_cmd git
need_cmd sh

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

info "Updating $APP_NAME"
info "repo:   $REPO_URL"
info "branch: $BRANCH"

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/$APP_NAME"

cd "$TMP_DIR/$APP_NAME"

sh ./install.sh

ok "Updated $APP_NAME"
