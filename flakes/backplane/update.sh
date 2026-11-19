#!/usr/bin/env bash
# Usage: ./update.sh [version]   (defaults to the latest GitHub release)
set -euo pipefail
cd "$(dirname "$0")"
repo=BackplaneWorks/Backplane

version=${1:-}
if [ -z "$version" ]; then
  version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)
fi
version=${version#v}

sums=$(curl -fsSL "https://github.com/$repo/releases/download/v$version/SHA256SUMS")
sri() {
  local hex
  hex=$(awk -v f="backplane-v$version-$1.tar.gz" '$2 == f {print $1}' <<<"$sums")
  [ -n "$hex" ] || { echo "no $1 tarball in v$version" >&2; exit 1; }
  nix hash convert --hash-algo sha256 --to sri "$hex"
}

jq -n --arg v "$version" --arg x64 "$(sri linux-x64)" --arg arm "$(sri linux-arm64)" '{
  version: $v,
  platforms: {
    "x86_64-linux": {target: "linux-x64", hash: $x64},
    "aarch64-linux": {target: "linux-arm64", hash: $arm}
  }
}' > sources.json

echo "backplane -> $version"
echo "now run: nix flake update backplane  (from the repo root)"
