#!/bin/bash
# Writes one role of this repository as a stand-alone role - the form that
# "ansible-galaxy role install" needs: the role's files at the top level.
#
#   tools/export-role.sh <role> <target directory>
set -euo pipefail

role="$1"
target="$2"
top="$(cd "$(dirname "$0")/.." && pwd)"
namespace="MojiX-Tech"

[ -d "${top}/roles/${role}" ] || { echo "No such role: ${role}" >&2; exit 2; }

mkdir -p "${target}"
cp -R "${top}/roles/${role}/." "${target}/"
cp "${top}/LICENSE" "${target}/LICENSE"

# Galaxy takes the name of a stand-alone role from its meta data
sed -i.bak "s/^galaxy_info:$/galaxy_info:\n  role_name: ${role}/" "${target}/meta/main.yml"

# the README speaks of the stand-alone role, not of the collection
sed -i.bak \
    -e "s|^# Role: ${role}\$|# Ansible Role: ${role}|" \
    -e "s|ansible-galaxy collection install mojix_tech.automation|ansible-galaxy role install ${namespace}.${role}|" \
    -e "s|mojix_tech\.automation\.${role}|${namespace}.${role}|g" \
    -e "s|(\.\./\.\./LICENSE)|(LICENSE)|" \
    "${target}/README.md"
rm -f "${target}/meta/main.yml.bak" "${target}/README.md.bak"

cat >> "${target}/README.md" <<NOTE

## Where this role comes from

This repository is written by the releases of
[MojiX-Tech/Automation](https://github.com/MojiX-Tech/Automation), where the role is developed
and tested. Please open issues and pull requests there. The same role is part of the
collection \`mojix_tech.automation\`.
NOTE
