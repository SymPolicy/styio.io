#!/usr/bin/env sh
set -eu

fail() {
  echo "smoke-site: $*" >&2
  exit 1
}

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

"$script_dir/build-site.sh" "$tmp_dir/site"

for path in \
  index.html \
  docs/index.html \
  docs/install.html \
  docs/release-hosting.html \
  docs/release-root-contract.html \
  assets/copy-code.js \
  assets/theme-init.js \
  assets/site.js \
  assets/sculpture.js \
  assets/sculpture.webp \
  assets/fonts/syne.woff2 \
  assets/fonts/dm-sans.woff2 \
  assets/styio-logo.svg \
  release-index.json \
  tools/pafio/install-pafio.sh
do
  [ -f "$tmp_dir/site/$path" ] || fail "missing built site file: $path"
done

if [ -e "$tmp_dir/site/docs/specs" ]; then
  fail "internal docs/specs must not be published"
fi

python3 - "$tmp_dir/site" <<'PY'
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import parse_qs, urlsplit
import re
import sys

root = Path(sys.argv[1])
versions = set()

def check_asset(url):
    parsed = urlsplit(url)
    if parsed.path != "/styles.css" and not parsed.path.startswith("/assets/"):
        return
    version = parse_qs(parsed.query).get("v", [])
    assert len(version) == 1 and version[0], f"unversioned built asset: {url}"
    assert (root / parsed.path.lstrip("/")).is_file(), f"missing built asset: {url}"
    versions.add(version[0])

class AssetLinks(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name in ("href", "src") and value:
                check_asset(value)

for path in root.rglob("*.html"):
    AssetLinks().feed(path.read_text())
for path in root.rglob("*.css"):
    for url in re.findall(r"url\(([^)]+)\)", path.read_text()):
        check_asset(url.strip("\"' "))
assert len(versions) == 1, "built pages and CSS must reference one asset version"
PY

for html in $(find "$repo_root" -name "*.html" -not -path "*/_site/*" -not -path "*/.git/*" | sort); do
  if grep -q "<pre><code" "$html"; then
    grep -q "/assets/copy-code.js" "$html" || fail "copy-code.js is not loaded by $html"
  fi
done

if find "$repo_root/tools" -path "*/releases/*" -type f | grep . >/dev/null 2>&1; then
  fail "binary release files must not be tracked under tools/*/releases/"
fi

if LC_ALL=C grep -R -n "[^ -~]" "$repo_root" \
  --exclude-dir=.git \
  --exclude-dir=.commandcode \
  --exclude-dir=_site \
  --exclude-dir=.release-bundle \
  --exclude-dir=output \
  --exclude-dir=.playwright-cli \
  --exclude="*.webp" \
  --exclude="*.woff2" \
  --exclude="*.png" >/dev/null 2>&1; then
  fail "non-ASCII text found in source"
fi

printf 'site smoke passed: %s\n' "$tmp_dir/site"
