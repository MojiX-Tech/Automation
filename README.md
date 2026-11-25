# Automation

Ansible roles for running Linux servers. Each role does one job, has safe defaults and a
README that says what it changes on the host.

## Roles

| Role | What it does |
|---|---|
| [`auditd`](roles/auditd/README.md) | Lean audit baseline: who did what, which security files changed. One weekly mail, only when something is notable. |
| [`aide`](roles/aide/README.md) | Lean file integrity check: one weekly mail, only for changes that no package update explains. |

## Use

Every role has its own playbook in `playbooks/`, named like the role.

### From a checkout

```bash
git clone https://github.com/MojiX-Tech/Automation.git
cd Automation
ansible-playbook -i "server1.example.com," playbooks/auditd.yml
ansible-playbook -i "server1.example.com," playbooks/aide.yml
```

Run them from the top folder of the checkout - its `ansible.cfg` tells Ansible where the
roles are.

### As a collection

The repository is also an Ansible collection, `mojix_tech.automation`:

```bash
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git,v1.2.0   # a fixed version
```

Then the playbooks run by name, from any folder:

```bash
ansible-playbook -i "server1.example.com," mojix_tech.automation.auditd
ansible-playbook -i "server1.example.com," mojix_tech.automation.aide
```

Or use a role in your own playbook:

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.auditd
      vars:
        auditd_report_email: admin@example.com
```

Set a role's variables with `-e` or in your inventory, for example
`-e auditd_report_email=admin@example.com`. Try it first with `--check --diff`.

## Requirements

- ansible-core 2.15 or newer on the control machine
- the targets each role names in its README (today: Debian 11 and 12)

## Layout

```
roles/<role>/           one directory per role, each with its own README
playbooks/<role>.yml    one playbook per role, named like the role
ansible.cfg             lets the playbooks find the roles in a checkout
galaxy.yml              collection name and version
```

A new role goes into `roles/<name>/` with `defaults/`, `tasks/`, `meta/main.yml` and a README,
gets its playbook `playbooks/<name>.yml` and a line in the table above.

## Licence

Apache License 2.0 - see [LICENSE](LICENSE).
