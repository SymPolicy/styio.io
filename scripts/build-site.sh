#!/usr/bin/env sh
set -eu

fail() {
  echo "build-site: $*" >&2
  exit 1
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
site_dir="${1:-$repo_root/_site}"
bundle="${2:-${RELEASE_ROOT_BUNDLE:-}}"

case "$site_dir" in
  /*) ;;
  *) site_dir="$repo_root/$site_dir" ;;
esac

rm -rf "$site_dir"
mkdir -p "$site_dir"

copy_path() {
  source_path="$repo_root/$1"
  [ -e "$source_path" ] || fail "missing site path: $1"
  cp -R "$source_path" "$site_dir/"
}

copy_optional_path() {
  source_path="$repo_root/$1"
  [ -e "$source_path" ] || return 0
  cp -R "$source_path" "$site_dir/"
}

copy_path ".nojekyll"
copy_path "404.html"
copy_path "CNAME"
copy_path "assets"
copy_path "docs"
copy_path "index.html"
copy_optional_path "release-index.json"
copy_optional_path "release-root.json"
copy_path "robots.txt"
copy_path "styles.css"
copy_path "tools"

# Internal specs are repository material, not published pages.
rm -rf "$site_dir/docs/specs"

# Keep each page and its presentation assets on the same release in browser/CDN caches.
asset_version="$(git -C "$repo_root" rev-parse --short=12 HEAD)"
python3 - "$site_dir" "$asset_version" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
version = sys.argv[2]
asset_url = re.compile(r'''(["'])(/(?:styles\.css|assets/[^"'\s?#]+))\1''')

def version_url(match):
    quote, path = match.groups()
    return f"{quote}{path}?v={version}{quote}"

for path in [*root.rglob("*.html"), *root.rglob("*.css")]:
    text = path.read_text()
    path.write_text(asset_url.sub(version_url, text))
PY

if [ -n "$bundle" ]; then
  case "$bundle" in
    /*) ;;
    *) bundle="$repo_root/$bundle" ;;
  esac
  [ -f "$bundle" ] || fail "release-root bundle does not exist: $bundle"

  tmp_dir="$(mktemp -d)"
  cleanup() {
    rm -rf "$tmp_dir"
  }
  trap cleanup EXIT INT TERM

  tar -xzf "$bundle" -C "$tmp_dir"
  find "$tmp_dir" -name "._*" -type f -delete
  [ -d "$tmp_dir/tools" ] || fail "release-root bundle must contain top-level tools/"
  rm -rf "$site_dir/tools"
  cp -R "$tmp_dir/tools" "$site_dir/tools"
  if [ -f "$tmp_dir/release-root.json" ]; then
    cp "$tmp_dir/release-root.json" "$site_dir/release-root.json"
  fi
fi

"$script_dir/validate-release-root.sh" "$site_dir"
