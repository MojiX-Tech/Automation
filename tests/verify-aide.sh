#!/bin/bash
# Runs inside the test machine after the role aide.
set -euo pipefail
step() { echo; echo "== $1"; }

step "Versions"
# shellcheck disable=SC1091
. /etc/os-release; echo "${PRETTY_NAME} (${VERSION_CODENAME})"
aide --version 2>&1 | head -n 1

step "Files of the role"
test -s /etc/aide/aide-lean.conf
test -s /var/lib/aide/aide-lean.db.gz
test -x /usr/local/bin/aide-report
crontab -l | grep aide-report

step "Nothing changed: no mail"
rm -f /tmp/mail.out
/usr/local/bin/aide-report
test ! -e /tmp/mail.out

step "A package is installed: explained, no mail"
apt-get install -y -qq tree > /dev/null
/usr/local/bin/aide-report | tee /tmp/out.txt
test ! -e /tmp/mail.out
grep -q 'explained by package updates' /tmp/out.txt

step "Changes by hand: one mail that names them"
echo "test" > /etc/zz-aide-test
echo "# test" >> /etc/issue
/usr/local/bin/aide-report
cat /tmp/mail.out
grep -q '/etc/zz-aide-test' /tmp/mail.out
grep -q '/etc/issue' /tmp/mail.out

step "Reported once: the next run is silent"
rm -f /tmp/mail.out
/usr/local/bin/aide-report
test ! -e /tmp/mail.out

echo
echo "ALL CHECKS PASSED"
