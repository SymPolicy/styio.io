#!/usr/bin/env sh
set -eu

fail() {
  echo "validate-release-root: $*" >&2
  exit 1
}

root="${1:-}"
[ -n "$root" ] || fail "usage: validate-release-root.sh <site-or-release-root>"
[ -d "$root" ] || fail "root is not a directory: $root"
[ -f "$root/tools/pafio/install-pafio.sh" ] || fail "missing tools/pafio/install-pafio.sh"

safe_segment() {
  case "$1" in
    ""|"."|".."|*[!A-Za-z0-9._-]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

sha256_value() {
  file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return 0
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return 0
  fi
  fail "sha256sum or shasum is required"
}

metadata_path="$root/release-root.json"
if [ "${REQUIRE_RELEASE_METADATA:-0}" = "1" ] && [ ! -f "$metadata_path" ]; then
  fail "release-root metadata is required but release-root.json is missing"
fi
if [ -f "$metadata_path" ]; then
  grep -q '"kind"[[:space:]]*:[[:space:]]*"release-root"' "$metadata_path" || fail "release-root.json must declare kind release-root"
  release_root_id="$(sed -n 's/.*"release_root_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$metadata_path" | head -n 1)"
  safe_segment "$release_root_id" || fail "unsafe release_root_id in release-root.json: $release_root_id"
fi

release_count=0
while IFS= read -r binary_path; do
  [ -n "$binary_path" ] || continue
  release_count=$((release_count + 1))
  sha_path="$binary_path.sha256"
  [ -f "$sha_path" ] || fail "missing checksum for $binary_path"
  expected="$(awk 'NF { print $1; exit }' "$sha_path")"
  case "$expected" in
    ""|*[!0-9a-f]*)
      fail "invalid sha256 text in $sha_path"
      ;;
  esac
  [ "${#expected}" -eq 64 ] || fail "invalid sha256 length in $sha_path"
  actual="$(sha256_value "$binary_path")"
  [ "$actual" = "$expected" ] || fail "checksum mismatch for $binary_path"
done <<EOF
$(find "$root/tools" -path "*/releases/*" -type f ! -name "*.sha256" | sort)
EOF

while IFS= read -r version_file; do
  [ -n "$version_file" ] || continue
  version="$(awk 'NF { print $1; exit }' "$version_file")"
  safe_segment "$version" || fail "unsafe version in $version_file: $version"
done <<EOF
$(find "$root/tools" -path "*/channel/*/*/version" -type f | sort)
EOF

if [ "${REQUIRE_RELEASE_BINARIES:-0}" = "1" ] && [ "$release_count" -eq 0 ]; then
  fail "release binaries are required but no tools/*/releases files were found"
fi

printf 'validated release root: %s (%s release binaries)\n' "$root" "$release_count"
