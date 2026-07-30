#!/usr/bin/env sh
set -eu

usage() {
  cat <<'USAGE'
Usage: install-pafio.sh [options]

Install a prebuilt Pafio binary from the styio.io static release root.
This installer installs Pafio only. Styio is a system-provided prerequisite.

Options:
  --base-url <url>      Release root, such as https://styio.io.
  --channel <name>      Release channel (default: latest).
  --version <value>     Exact release version; skips channel lookup.
  --binary-url <url>    Exact Pafio binary URL; bypasses release lookup.
  --sha256-url <url>    Exact checksum URL.
  --platform <value>    Release platform key; defaults to uname detection.
  --install-dir <dir>   Install directory (default: /usr/local/bin).
  --binary-name <name>  Installed executable name (default: pafio).
  --print-platform      Print the detected release platform and exit.
  -h, --help            Show this help.
USAGE
}

fail() {
  echo "install-pafio: $*" >&2
  exit 1
}

lowercase() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'
}

detect_linux_libc() {
  if [ -n "${PAFIO_INSTALL_LIBC:-}" ]; then
    case "$(lowercase "$PAFIO_INSTALL_LIBC")" in
      glibc|musl) lowercase "$PAFIO_INSTALL_LIBC"; return 0 ;;
      *) fail "unsupported PAFIO_INSTALL_LIBC value: $PAFIO_INSTALL_LIBC" ;;
    esac
  fi
  if [ -e /etc/alpine-release ]; then
    echo "musl"
  elif command -v ldd >/dev/null 2>&1 &&
       ldd --version 2>&1 | grep -qi musl; then
    echo "musl"
  else
    echo "glibc"
  fi
}

detect_platform() {
  os="$(lowercase "${PAFIO_INSTALL_UNAME_S:-$(uname -s)}")"
  arch="$(lowercase "${PAFIO_INSTALL_UNAME_M:-$(uname -m)}")"
  case "$os" in
    linux)
      if [ "$(detect_linux_libc)" = "musl" ]; then
        os="linux-musl"
      fi
      ;;
    darwin) ;;
    *) fail "unsupported OS for automatic platform detection: $os" ;;
  esac
  case "$arch" in
    aarch64|arm64) arch="aarch64" ;;
    x86_64|amd64) arch="x86_64" ;;
    *) fail "unsupported CPU for automatic platform detection: $arch" ;;
  esac
  printf '%s-%s\n' "$os" "$arch"
}

sha256_value() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    fail "sha256sum or shasum is required"
  fi
}

safe_segment() {
  case "$1" in
    ""|"."|".."|*[!A-Za-z0-9._-]*) return 1 ;;
    *) return 0 ;;
  esac
}

BASE_URL="${PAFIO_INSTALL_BASE_URL:-}"
BINARY_URL="${PAFIO_INSTALL_BINARY_URL:-}"
SHA256_URL="${PAFIO_INSTALL_SHA256_URL:-}"
CHANNEL="${PAFIO_INSTALL_CHANNEL:-latest}"
RELEASE_VERSION="${PAFIO_INSTALL_VERSION:-}"
PLATFORM="${PAFIO_INSTALL_PLATFORM:-}"
INSTALL_DIR="${PAFIO_INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="${PAFIO_INSTALL_BINARY_NAME:-pafio}"
PRINT_PLATFORM=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --base-url) [ "$#" -ge 2 ] || fail "--base-url requires a value"; BASE_URL="$2"; shift 2 ;;
    --channel) [ "$#" -ge 2 ] || fail "--channel requires a value"; CHANNEL="$2"; shift 2 ;;
    --version) [ "$#" -ge 2 ] || fail "--version requires a value"; RELEASE_VERSION="$2"; shift 2 ;;
    --binary-url) [ "$#" -ge 2 ] || fail "--binary-url requires a value"; BINARY_URL="$2"; shift 2 ;;
    --sha256-url) [ "$#" -ge 2 ] || fail "--sha256-url requires a value"; SHA256_URL="$2"; shift 2 ;;
    --platform) [ "$#" -ge 2 ] || fail "--platform requires a value"; PLATFORM="$2"; shift 2 ;;
    --install-dir) [ "$#" -ge 2 ] || fail "--install-dir requires a value"; INSTALL_DIR="$2"; shift 2 ;;
    --binary-name) [ "$#" -ge 2 ] || fail "--binary-name requires a value"; BINARY_NAME="$2"; shift 2 ;;
    --print-platform) PRINT_PLATFORM=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done

if [ "$PRINT_PLATFORM" -eq 1 ]; then
  detect_platform
  exit 0
fi

command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v install >/dev/null 2>&1 || fail "install is required"

if [ -z "$BINARY_URL" ]; then
  [ -n "$BASE_URL" ] || fail "pass --base-url or --binary-url"
  BASE_URL="${BASE_URL%/}"
  [ -n "$PLATFORM" ] || PLATFORM="$(detect_platform)"
  safe_segment "$CHANNEL" || fail "unsafe channel: $CHANNEL"
  if [ -z "$RELEASE_VERSION" ]; then
    RELEASE_VERSION="$(
      curl -fsSL "$BASE_URL/tools/pafio/channel/$CHANNEL/$PLATFORM/version" |
        awk 'NF { print $1; exit }'
    )"
  fi
  safe_segment "$RELEASE_VERSION" || fail "unsafe release version: $RELEASE_VERSION"
  BINARY_URL="$BASE_URL/tools/pafio/releases/$RELEASE_VERSION/$PLATFORM/pafio"
  [ -n "$SHA256_URL" ] || SHA256_URL="$BINARY_URL.sha256"
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

tmp_binary="$tmp_dir/pafio"
curl -fsSL "$BINARY_URL" -o "$tmp_binary"
if [ -n "$SHA256_URL" ]; then
  expected="$(
    curl -fsSL "$SHA256_URL" |
      awk 'NF { print $1; exit }'
  )"
  safe_segment "$expected" || fail "invalid checksum response"
  [ "${#expected}" -eq 64 ] || fail "invalid sha256 length"
  actual="$(sha256_value "$tmp_binary")"
  [ "$actual" = "$expected" ] ||
    fail "sha256 mismatch for downloaded Pafio binary"
fi
chmod 0755 "$tmp_binary"

if [ -d "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ]; then
  install -m 0755 "$tmp_binary" "$INSTALL_DIR/$BINARY_NAME"
elif [ ! -e "$INSTALL_DIR" ] && [ -w "$(dirname "$INSTALL_DIR")" ]; then
  mkdir -p "$INSTALL_DIR"
  install -m 0755 "$tmp_binary" "$INSTALL_DIR/$BINARY_NAME"
elif command -v sudo >/dev/null 2>&1; then
  sudo install -d -m 0755 "$INSTALL_DIR"
  sudo install -m 0755 "$tmp_binary" "$INSTALL_DIR/$BINARY_NAME"
else
  fail "$INSTALL_DIR is not writable; pass --install-dir \$HOME/.local/bin"
fi

echo "installed $INSTALL_DIR/$BINARY_NAME"
echo "Styio is system-provided; verify it separately with: styio --version"
