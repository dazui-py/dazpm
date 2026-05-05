cat > install.sh <<'EOF'
#!/usr/bin/env sh
set -eu

APP_NAME="dazpm"

: "${PREFIX:?PREFIX is not set. Run this inside Termux or export PREFIX first.}"

INSTALL_DIR="${DAZPM_INSTALL_DIR:-"$PREFIX/share/dazpm"}"
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

need_cmd zsh

if ! command -v git >/dev/null 2>&1; then
  warn "git not found. dazpm will install, but Git packages will not work until git is installed."
fi

info "Installing $APP_NAME"
info "source: $SRC_DIR"
info "target: $INSTALL_DIR"

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share"

if [ "$SRC_DIR" != "$INSTALL_DIR" ]; then
  TMP_DIR="${INSTALL_DIR}.tmp"

  rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"

  cp -R "$SRC_DIR"/. "$TMP_DIR"/

  rm -rf \
    "$TMP_DIR/.git" \
    "$TMP_DIR/.dazpm-hardening-backup-"* \
    "$TMP_DIR/apply-dazpm-hardening.py" \
    "$TMP_DIR/dazpm-hardening.patch" 2>/dev/null || true

  rm -rf "$INSTALL_DIR"
  mv "$TMP_DIR" "$INSTALL_DIR"
else
  info "Already running from install directory"
fi

chmod +x "$INSTALL_DIR/bin/dazpm"

ln -sf "$INSTALL_DIR/bin/dazpm" "$BIN_FILE"

ok "Installed source: $INSTALL_DIR"
ok "Installed command: $BIN_FILE"

"$BIN_FILE" init

ok "Done"
info "Restart zsh or run: source ~/.zshrc"
info "Then test: dazpm doctor"
EOF

chmod +x install.sh
