# Automation

Ansible roles for running Linux servers. Each role does one job, has safe defaults and a
README that says what it changes on the host.

## Roles

| Role | What it does |
|---|---|
| [`auditd`](roles/auditd/README.md) | Lean audit baseline: who did what, which security files changed. One weekly mail, only when something is notable. |
| [`aide`](roles/aide/README.md) | Lean file integrity check: one weekly mail, only for changes that no package update explains. |

## Install

The repository is an Ansible collection, `mojix_tech.automation`:

```bash
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git
```

A fixed version:

```bash
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git,v1.0.0
```

## Use

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.auditd
      vars:
        auditd_report_email: admin@example.com
    - role: mojix_tech.automation.aide
      vars:
        aide_report_email: admin@example.com
```

Or the ready playbook for both:

```bash
ansible-playbook -i inventory.ini mojix_tech.automation.security_baseline -e report_email=admin@example.com
```

Try a role on one host first:

```bash
ansible-playbook -i "server1.example.com," site.yml --check --diff
```

## Requirements

- ansible-core 2.15 or newer on the control machine
- the targets each role names in its README (today: Debian 11 and 12)

## Layout

```
galaxy.yml              collection name and version
roles/<role>/           one directory per role, each with its own README
playbooks/              ready playbooks that combine roles
```

A new role goes into `roles/<name>/` with `defaults/`, `tasks/`, `meta/main.yml` and a README,
and gets a line in the table above.

## Licence

Apache License 2.0 - see [LICENSE](LICENSE).
