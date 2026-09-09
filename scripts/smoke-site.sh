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
  docs/dns-and-pages.html \
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
