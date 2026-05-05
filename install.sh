#!/usr/bin/env sh
set -eu

APP_NAME="dazpm"
REPO_URL="${DAZPM_REPO_URL:-https://github.com/dazui-py/dazpm.git}"

: "${PREFIX:?PREFIX is not set. Run this inside Termux or export PREFIX first.}"

INSTALL_DIR="${DAZPM_INSTALL_DIR:-"$PREFIX/share/dazpm"}"
STATE_DIR="${DAZPM_HOME:-"$PREFIX/share/dazpm-home"}"
BIN_FILE="$PREFIX/bin/dazpm"

SRC_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"

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

warn() {
  printf '%s\n' "[!] $*" >&2
}

copy_source() {
  src="$1"
  dest="$2"
  tmp="${dest}.tmp"

  rm -rf "$tmp"
  mkdir -p "$tmp"

  (
    cd "$src"

    tar \
      --exclude='./.git' \
      --exclude='./.git/*' \
      --exclude='./.dazpm-hardening-backup-*' \
      --exclude='./apply-dazpm-hardening.py' \
      --exclude='./dazpm-hardening.patch' \
      -cf - .
  ) | (
    cd "$tmp"
    tar -xf -
  )

  rm -rf "$dest"
  mv "$tmp" "$dest"
}

need_cmd zsh
need_cmd tar

if ! command -v git >/dev/null 2>&1; then
  warn "git not found. dazpm will install, but Git packages will not work until git is installed."
fi

info "Installing $APP_NAME"
info "source: $SRC_DIR"
info "target: $INSTALL_DIR"
info "state:  $STATE_DIR"

mkdir -p "$PREFIX/bin" "$PREFIX/share"

if [ "$SRC_DIR" != "$INSTALL_DIR" ]; then
  copy_source "$SRC_DIR" "$INSTALL_DIR"
else
  info "Already running from install directory"
fi

chmod +x "$INSTALL_DIR/bin/dazpm"

ln -sf "$INSTALL_DIR/bin/dazpm" "$BIN_FILE"

mkdir -p "$STATE_DIR"

DAZPM_HOME="$STATE_DIR" "$BIN_FILE" init

ok "Installed source: $INSTALL_DIR"
ok "Installed state:  $STATE_DIR"
ok "Installed command: $BIN_FILE"
ok "Done"

info "Restart zsh or run: source ~/.zshrc"
info "Then test: dazpm doctor"
