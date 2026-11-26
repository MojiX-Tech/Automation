#!/bin/bash
# Runs inside the test machine after the role auditd.
set -euo pipefail
step() { echo; echo "== $1"; }

step "Versions"
# shellcheck disable=SC1091
. /etc/os-release; echo "${PRETTY_NAME} (${VERSION_CODENAME})"
auditctl -v

step "Files of the role"
test -s /etc/audit/rules.d/audit.rules
test -s /etc/audit/rules.d/custom.rules
test -x /usr/local/bin/audit-report
grep -q '^# session.*pam_loginuid' /etc/pam.d/cron
crontab -l | grep audit-report

step "The journal keeps no copy of the audit events"
state=$(systemctl is-enabled systemd-journald-audit.socket 2>&1 || true)
echo "${state}"
[ "${state}" = "masked" ]

step "auditd runs and the rules are loaded"
systemctl is-active auditd
auditctl -l > /tmp/rules.txt
cat /tmp/rules.txt
grep -q 'user_cmd' /tmp/rules.txt
grep -q -- '-w /etc/passwd -p wa -k identity' /tmp/rules.txt

step "A quiet week sends no mail"
rm -f /tmp/mail.out
/usr/local/bin/audit-report
test ! -e /tmp/mail.out

step "A change of a security file is recorded and reported"
echo "# test" > /etc/sudoers.d/zz-test
sleep 3
ausearch --input-logs -k sudoers -i | tail -n 5
/usr/local/bin/audit-report
cat /tmp/mail.out
grep -q 'sudoers' /tmp/mail.out

echo
echo "ALL CHECKS PASSED"
