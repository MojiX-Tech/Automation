#!/bin/bash
# Publishes one role as a stand-alone role: writes it into its own repository
# (ansible-role-<role>), tags the version and lets Ansible Galaxy import it.
# A role that did not change since the last release is left alone.
#
#   tools/publish-role.sh <role> <version>
#
# ROLE_REPO_URL   git address of the role's repository (default: SSH)
# GALAXY_API_KEY  token for the import (default: the token file of ansible-galaxy)
set -euo pipefail

role="$1"
version="$2"
top="$(cd "$(dirname "$0")/.." && pwd)"
owner="MojiX-Tech"
repo="ansible-role-${role}"
url="${ROLE_REPO_URL:-git@github.com:${owner}/${repo}.git}"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

git clone -q "${url}" "${work}/repo" 2>/dev/null || { echo "Cannot clone ${url}" >&2; exit 1; }
cd "${work}/repo"
git checkout -q -B main

# the repository holds exactly what the export writes
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
"${top}/tools/export-role.sh" "${role}" "${work}/repo" > /dev/null

git add -A
if git diff --cached --quiet; then
    echo "${role}: unchanged since its last release - nothing published"
    exit 0
fi

git -c user.name="${owner}" -c user.email="23185356+${owner}@users.noreply.github.com" \
    commit -q -m "Release ${version}"
git tag "${version}"
git push -q origin main
git push -q origin "${version}"
echo "${role}: ${version} pushed to ${owner}/${repo}"

if [ -n "${GALAXY_API_KEY:-}" ]; then
    ansible-galaxy role import --token "${GALAXY_API_KEY}" "${owner}" "${repo}"
else
    ansible-galaxy role import "${owner}" "${repo}"
fi
