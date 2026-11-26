# Automation

[![test](https://github.com/MojiX-Tech/Automation/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/MojiX-Tech/Automation/actions/workflows/test.yml)
[![lint](https://github.com/MojiX-Tech/Automation/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/MojiX-Tech/Automation/actions/workflows/lint.yml)
[![galaxy](https://img.shields.io/ansible/collection/v/mojix_tech/automation)](https://galaxy.ansible.com/ui/repo/published/mojix_tech/automation/)
[![license](https://img.shields.io/github/license/MojiX-Tech/Automation)](LICENSE)

Ansible roles for running Linux servers. Each role does one job, has safe defaults and a
README that says what it changes on the host.

## Install

```bash
ansible-galaxy collection install mojix_tech.automation
```

This installs the whole collection - a few small files. Nothing runs on a host until you
name a role in a playbook.

## Use only the roles you need

| Role | What it does | Use it as |
|---|---|---|
| [`auditd`](https://github.com/MojiX-Tech/Automation/blob/main/roles/auditd/README.md) | Lean audit baseline: who did what, which security files changed. One weekly mail, only when something is notable. | `mojix_tech.automation.auditd` |
| [`aide`](https://github.com/MojiX-Tech/Automation/blob/main/roles/aide/README.md) | Lean file integrity check: one weekly mail, only for changes that no package update explains. | `mojix_tech.automation.aide` |
| [`fail2ban`](https://github.com/MojiX-Tech/Automation/blob/main/roles/fail2ban/README.md) | Bans hosts that keep failing to log in: reads the journal, bans with nftables, longer bans for hosts that come back. | `mojix_tech.automation.fail2ban` |

The roles do not depend on each other. Take one, several or all:

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.aide
      vars:
        aide_report_email: admin@example.com
```

Without a playbook of your own - every role brings one, named like the role:

```bash
ansible-playbook -i "server1.example.com," mojix_tech.automation.aide
```

Set a role's variables in the playbook, in your inventory or with `-e`, for example
`-e aide_report_email=admin@example.com`. Try it first with `--check --diff`.
Each role's README lists its variables and says what it changes on the host.

## Tested

Every push runs every role on every supported OS version, each in a fresh virtual machine:
a wrong value is refused before anything is changed, the role runs, runs a second time
without changing anything, a dry run (`--check`) works, and a script on the machine checks
that the role does what its README says (for example: a changed security file ends up in the
weekly mail, a package update does not).

Every role checks its variables before it starts: a wrong type or an unknown choice stops the
run with a clear message, before the host is touched.

## One role without the collection

Every role is also published by itself, as a stand-alone role:

```bash
ansible-galaxy role install MojiX-Tech.aide
```

```yaml
- hosts: all
  become: true
  roles:
    - role: MojiX-Tech.aide
```

It is the same role with a shorter name: `MojiX-Tech.<role>` instead of
`mojix_tech.automation.<role>`. Each has its own repository, `ansible-role-<role>`, which is
written by the releases of this one - changes are made here.

## Other ways to get it

A fixed version:

```bash
ansible-galaxy collection install mojix_tech.automation:1.5.0
```

Straight from GitHub, without Ansible Galaxy:

```bash
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git
```

From a checkout, without installing anything:

```bash
git clone https://github.com/MojiX-Tech/Automation.git
cd Automation
ansible-playbook -i "server1.example.com," playbooks/aide.yml
```

Run the playbooks from the top folder of the checkout - its `ansible.cfg` tells Ansible where
the roles are.

## Requirements

- ansible-core 2.15 or newer on the control machine
- targets: Debian 12 and 13, Ubuntu 22.04, 24.04 and 26.04 (the newest release and the two
  before it; Debian 11 has reached its end of life and is no longer tested)

## Layout

```
roles/<role>/           one directory per role, each with its own README
playbooks/<role>.yml    one playbook per role, named like the role
ansible.cfg             lets the playbooks find the roles in a checkout
galaxy.yml              collection name and version
tests/                  boots a virtual machine per OS version and checks each role on it
tools/                  publishes each role as a stand-alone role at a release
.github/workflows/      checks on every push; a version tag publishes to Ansible Galaxy
```

A new role goes into `roles/<name>/` with `defaults/`, `tasks/`, `meta/main.yml` and a README,
gets its playbook `playbooks/<name>.yml` and a line in the table above. Run
`tools/new-role-repo.sh <name>` once, so that the release can publish it by itself too.

## Help and changes

- What changed in which version: [CHANGELOG.md](CHANGELOG.md) and the
  [releases](https://github.com/MojiX-Tech/Automation/releases)
- A bug or a question: [open an issue](https://github.com/MojiX-Tech/Automation/issues)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)
- A security problem: [SECURITY.md](SECURITY.md)

## Licence

Apache License 2.0 - see [LICENSE](LICENSE).
