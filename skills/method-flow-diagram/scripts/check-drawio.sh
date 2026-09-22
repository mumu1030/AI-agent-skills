#!/usr/bin/env bash
# Locate the draw.io desktop CLI. Prints the absolute path on success.
# Usage: check-drawio.sh
set -euo pipefail

if command -v draw.io >/dev/null 2>&1; then
  command -v draw.io
  exit 0
fi

MAC_APP="/Applications/draw.io.app/Contents/MacOS/draw.io"
if [[ -x "$MAC_APP" ]]; then
  echo "$MAC_APP"
  exit 0
fi

echo "NOT_FOUND"
exit 1
