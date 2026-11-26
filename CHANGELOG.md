# Changelog

## 1.5.0

- Every role checks its variables before it starts (`meta/argument_specs.yml`): a wrong type or
  an unknown choice stops the run before the host is touched.
- The tests also prove that a wrong value is refused and that a dry run (`--check`) works.
- Every version is a release on GitHub with its notes.
- New: `SECURITY.md`, `CONTRIBUTING.md`, a form for bug reports.

## 1.4.0

- New role `fail2ban`: reads the journal, bans with nftables, longer bans for hosts that come back.

## 1.3.1

- Every role is also published as a stand-alone role: `ansible-galaxy role install MojiX-Tech.<role>`.

## 1.3.0

- Both roles support Debian 12 and 13 and Ubuntu 22.04, 24.04 and 26.04, and are tested on each
  of them in a virtual machine on every push.
- Both roles install `cron` when the weekly report is on (a minimal system has none).
- Both roles install only the packages they name, without the recommended ones - `aide` and
  `cron` would otherwise bring a mail server along.
- Role `auditd`: files that do not exist on a system are skipped (`/etc/pam.d/cron`,
  `/etc/pam.d/sshd`, journald's audit socket).
- Role `aide`: the units of snaps are left out (Ubuntu rewrites them at every snap refresh).
- Debian 11 is no longer listed: it has reached its end of life.

## 1.2.3

- Automatic checks on every push; a version tag publishes the collection to Ansible Galaxy.

## 1.2.2

- README: install first, then a table of the roles with the name to use for each.

## 1.2.1

- README: install from Ansible Galaxy.

## 1.2.0

- The playbooks of the roles moved to `playbooks/` (`playbooks/auditd.yml`, `playbooks/aide.yml`).
  Installed as a collection they run by name: `mojix_tech.automation.auditd`.

## 1.1.1

- Removed the playbook `security_baseline`; every role has its own playbook.

## 1.1.0

- One playbook per role in the top folder: `auditd.yml`, `aide.yml`.

## 1.0.1

- Role `aide`: the default excludes name only files of the base system.

## 1.0.0

- New role `auditd`: lean audit baseline with one weekly mail.
- New role `aide`: lean file integrity check with one weekly mail.
- New playbook `security_baseline`: both roles for every host of the inventory.
