# Role: auditd

A lean auditd baseline for servers. It answers two questions and nothing else:

1. **Who did what?** Every command of a logged-in person is recorded - also after `sudo` or
   `su`, because the login ID stays with the person.
2. **What changed?** Every write to a security-relevant file is recorded, whoever did it.

Services, cron jobs and containers are *not* recorded command by command. That keeps the log
small enough to keep for weeks and readable when you need it.

Once a week the host sends **one mail, and only when something is notable**: a security file
changed, audit events were lost, or auditd stopped writing its log.

## Requirements

- Debian 11 or 12 (the role uses `apt`; other Debian-based systems may work but are not tested)
- root on the target (`become: true`)
- for the weekly mail: the host can send mail with the `mail` command. The role installs no
  mail software. Without it, set `auditd_report_enabled: false`.

## Install

```bash
ansible-galaxy collection install git+https://github.com/MojiX-Tech/Automation.git
```

## Example playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.auditd
      vars:
        auditd_report_email: admin@example.com
```

With options:

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.auditd
      vars:
        auditd_report_email: admin@example.com
        # the monitoring server logs in every minute - do not record its commands
        auditd_ssh_unaudited_hosts: [192.0.2.10]
        # one more file to watch
        auditd_extra_watches:
          - { path: /etc/myapp/secrets.env, key: secrets }
```

## What is recorded

| Key | What |
|---|---|
| `user_cmd` | every command of a logged-in user |
| `identity` | `/etc/passwd`, `shadow`, `group`, `gshadow`, `security/opasswd` |
| `sudoers` | `/etc/sudoers`, `/etc/sudoers.d/` |
| `sshd` | `/etc/ssh/sshd_config`, `sshd_config.d/` |
| `ssh_keys` | `/root/.ssh/` |
| `pam`, `login` | `/etc/pam.d/`, `/etc/login.defs` |
| `cron` | `/etc/crontab`, `/etc/cron.d/`, `/var/spool/cron/` |
| `systemd` | `/etc/systemd/system/` |
| `network` | `/etc/hosts`, `/etc/hostname`, hostname changes |
| `firewall` | `/etc/nftables.conf`, `/etc/nftables/` |
| `modules` | `/etc/modprobe.d/`, loading and unloading of kernel modules, kexec |
| `time` | `/etc/localtime`, clock changes by users |
| `mount` | mounts and unmounts by users |
| `auditconfig`, `auditlog`, `audittools` | the audit system itself |

A path that does not exist on a host is left out.

Search: `ausearch --input-logs -k <key> -i`. Summary: `aureport --input-logs -k -i`.

## Variables

All variables with their explanation are in [`defaults/main.yml`](defaults/main.yml).
The ones you are most likely to set:

| Variable | Default | Meaning |
|---|---|---|
| `auditd_report_email` | `root` | receiver of the weekly mail |
| `auditd_report_enabled` | `true` | weekly report on or off |
| `auditd_report_alert_keys` | see defaults | keys that are a reason to send the mail |
| `auditd_max_log_file` / `auditd_num_logs` | `50` / `10` | size (MB) and number of log files kept |
| `auditd_extra_watches` | `[]` | more paths to watch for writes |
| `auditd_ssh_unaudited_hosts` | `[]` | addresses of trusted machines whose SSH sessions are not recorded command by command |
| `auditd_unaudited_auids` | `[]` | login IDs that are no people |
| `auditd_exclude_user_msgtypes` / `auditd_exclude_kernel_msgtypes` | `[]` | record types that are never written |
| `auditd_cron_loginuid` | `false` | `true` records the commands of cron jobs as user commands |
| `auditd_journald_copy` | `false` | `true` keeps a second copy of the audit events in the journal |
| `auditd_root_linger` | `false` | keeps root's user manager running (hosts with many automatic root logins) |
| `auditd_enable_flag` | `1` | `2` locks the rules until the next reboot |

## What the role changes besides auditd

Please read this before the first run - the role touches three places outside `/etc/audit`:

- **`/etc/pam.d/cron`**: the line `session required pam_loginuid.so` is commented out, so cron
  jobs get no login ID and are not recorded as user commands (`auditd_cron_loginuid: true`
  puts it back).
- **`/etc/pam.d/sshd`**: only when `auditd_ssh_unaudited_hosts` is set - one line that skips
  `pam_loginuid` for these addresses.
- **`systemd-journald-audit.socket`**: masked, so the journal holds no second copy of the
  audit events (`auditd_journald_copy: true` keeps it).

## The weekly mail

`/usr/local/bin/audit-report` runs from root's crontab (Sunday 10:30 by default) and stays
silent in a normal week. Subjects:

- `[auditd] Weekly Report - <host>` - a file behind one of the alert keys changed, or audit
  events were lost.
- `[auditd] NOT LOGGING - <host>` - auditd is running but nothing reaches the log. This
  happens after a full disk: auditd suspends writing and does not resume by itself. Fix the
  disk, then `systemctl restart auditd`.

The script sends a test record through the kernel and auditd on every run to find out.

## Tags

`auditd_install`, `auditd_config`, `auditd_rules`, `auditd_report`

## Licence

Apache License 2.0 - see [LICENSE](../../LICENSE).
