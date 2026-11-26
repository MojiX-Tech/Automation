# Changelog

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
