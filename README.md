# Automation

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
the role runs, runs a second time without changing anything, and a script on the machine
checks that it does what its README says (for example: a changed security file ends up in
the weekly mail, a package update does not).

## Other ways to get it

A fixed version:

```bash
ansible-galaxy collection install mojix_tech.automation:1.3.0
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
.github/workflows/      checks on every push; a version tag publishes to Ansible Galaxy
```

A new role goes into `roles/<name>/` with `defaults/`, `tasks/`, `meta/main.yml` and a README,
gets its playbook `playbooks/<name>.yml` and a line in the table above.

## Licence

Apache License 2.0 - see [LICENSE](LICENSE).
