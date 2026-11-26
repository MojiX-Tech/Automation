#!/bin/bash
# Once per new role, on a machine where "gh" is logged in: creates the public
# repository ansible-role-<role> and gives the release workflow of this
# repository the right to write into it (a deploy key, stored as a secret).
#
#   tools/new-role-repo.sh <role>
set -euo pipefail

role="$1"
owner="MojiX-Tech"
repo="${owner}/ansible-role-${role}"
secret="DEPLOY_KEY_$(echo "${role}" | tr '[:lower:]-' '[:upper:]_')"
top="$(cd "$(dirname "$0")/.." && pwd)"

[ -d "${top}/roles/${role}" ] || { echo "No such role: ${role}" >&2; exit 2; }
description=$(sed -n 's/^  description: *//p' "${top}/roles/${role}/meta/main.yml")

if gh repo view "${repo}" > /dev/null 2>&1; then
    echo "${repo} exists already"
else
    gh repo create "${repo}" --public --description "Ansible role ${role}: ${description}" > /dev/null
    echo "Created ${repo}"
fi

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
ssh-keygen -q -t ed25519 -N '' -C "release of ${owner}/Automation" -f "${work}/key"
gh repo deploy-key add "${work}/key.pub" --repo "${repo}" --allow-write --title "Automation release" > /dev/null
gh secret set "${secret}" --repo "${owner}/Automation" < "${work}/key"
echo "Deploy key added to ${repo}, private half stored as the secret ${secret} of ${owner}/Automation"
