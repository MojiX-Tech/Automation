#!/bin/bash
# Runs inside the test machine after the role fail2ban.
set -euo pipefail
step() { echo; echo "== $1"; }

step "Versions"
# shellcheck disable=SC1091
. /etc/os-release; echo "${PRETTY_NAME} (${VERSION_CODENAME})"
fail2ban-client --version

step "Files of the role"
test -s /etc/fail2ban/jail.local
test -s /etc/fail2ban/fail2ban.local

step "fail2ban runs and the sshd jail is up"
systemctl is-active fail2ban
systemctl is-enabled fail2ban
fail2ban-client status
fail2ban-client status sshd
[ "$(fail2ban-client get sshd bantime)" = "3600" ]
[ "$(fail2ban-client get sshd maxretry)" = "5" ]

step "Failed logins in the journal are recognised"
for _ in 1 2 3; do
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
        nosuchuser@127.0.0.1 true 2>/dev/null || true
done
sleep 3
fail2ban-regex systemd-journal /etc/fail2ban/filter.d/sshd.conf | tee /tmp/regex.txt | grep -E '^Lines:|matched'
matched=$(sed -n 's/^Lines:.* \([0-9][0-9]*\) matched.*/\1/p' /tmp/regex.txt)
echo "matched lines: ${matched}"
[ "${matched:-0}" -gt 0 ]

step "A ban becomes a rule in fail2ban's nftables table"
fail2ban-client set sshd banip 192.0.2.99
sleep 2
fail2ban-client status sshd | grep '192.0.2.99'
nft list table inet f2b-table | tee /tmp/nft.txt
grep -q '192.0.2.99' /tmp/nft.txt

step "An unban removes it"
fail2ban-client set sshd unbanip 192.0.2.99
sleep 2
if nft list table inet f2b-table 2>/dev/null | grep -q '192.0.2.99'; then
    echo "192.0.2.99 is still in the table"; exit 1
fi

echo
echo "ALL CHECKS PASSED"
