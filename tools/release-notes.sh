#!/bin/bash
# Prints the section of one version from CHANGELOG.md.
#
#   tools/release-notes.sh <version>
set -euo pipefail
top="$(cd "$(dirname "$0")/.." && pwd)"
awk -v version="$1" '$0 == "## " version {found = 1; next} /^## / {found = 0} found' "${top}/CHANGELOG.md" | sed -e '/./,$!d'
