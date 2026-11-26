# Role: fail2ban

fail2ban that works right after the run. It watches the failed SSH logins and bans a host
that keeps trying - for an hour at first, and longer each time the host comes back.

Two things make it work where the distribution's own setup does not:

- **It reads the journal.** A current Debian writes no `/var/log/auth.log` any more; fail2ban
  as installed there finds no log file and does not start.
- **It bans with nftables**, in a table of its own. The firewall rules of the host are not
  read and not changed, so it works the same with any firewall or with none.

## Requirements

- Debian 12 or 13, Ubuntu 22.04, 24.04 or 26.04 - every release of this role is tested on each
  of them in a fresh virtual machine
- root on the target (`become: true`)

## Install

```bash
ansible-galaxy collection install mojix_tech.automation
```

## Example playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.fail2ban
```

With options:

```yaml
- hosts: all
  become: true
  roles:
    - role: mojix_tech.automation.fail2ban
      vars:
        # never ban the office and the monitoring server
        fail2ban_ignoreip:
          - 198.51.100.0/24
          - 192.0.2.10
        fail2ban_maxretry: 3
        fail2ban_bantime: 1d
        fail2ban_jails:
          - name: sshd
            port: 2222
          - name: nginx-http-auth
```

**Before the first run:** put the addresses you log in from into `fail2ban_ignoreip` - a few
wrong passwords from your own address would lock you out for the ban time.

## What the role changes on the host

- **Packages:** `fail2ban`, `python3-systemd` (to read the journal) and `nftables` (the `nft`
  command). Recommended packages are not installed. The `nftables` service is not enabled and
  `/etc/nftables.conf` is not touched.
- **`/etc/fail2ban/jail.local`:** the settings below and the jails. The files of the
  distribution (`jail.conf`, `jail.d/`) stay as they are; `jail.local` wins over them.
- **`/etc/fail2ban/fail2ban.local`:** log level and how long bans are remembered.
- **The service `fail2ban`** is enabled and started.

At the first ban fail2ban creates its own nftables table (`inet f2b-table`) and removes it
when it stops. Nothing else is written to the firewall.

## Variables

| Variable | Default | Meaning |
|---|---|---|
| `fail2ban_ignoreip` | `[]` | addresses and networks that are never banned (the host itself never is) |
| `fail2ban_maxretry` | `5` | failures until a ban |
| `fail2ban_findtime` | `10m` | ... within this time |
| `fail2ban_bantime` | `1h` | length of the first ban |
| `fail2ban_bantime_increment` | `true` | a host that comes back is banned longer each time |
| `fail2ban_bantime_maxtime` | `1w` | the longest ban |
| `fail2ban_jails` | `[{name: sshd}]` | the jails; every key besides `name` is written into the jail as it is |
| `fail2ban_backend` | `systemd` | where the failures are read: the journal |
| `fail2ban_banaction` / `fail2ban_banaction_allports` | `nftables-multiport` / `nftables-allports` | how a host is banned |
| `fail2ban_action` | `%(action_)s` | ban only; `%(action_mw)s` also sends a mail |
| `fail2ban_destemail` / `fail2ban_sender` | `root` / `fail2ban@<host>` | for the mail, when `fail2ban_action` sends one |
| `fail2ban_loglevel` | `INFO` | log level of fail2ban |
| `fail2ban_dbpurgeage` | `8d` | how long a ban is remembered; keep it longer than the longest ban |
| `fail2ban_packages` | see defaults | the packages that are installed |

Times are seconds or a number with a unit: `10m`, `1h`, `1d`, `1w`.

A jail name must be one that fail2ban ships (`/etc/fail2ban/jail.conf` lists them). A jail for
a service that is not installed stops fail2ban from starting - name only what runs on the host.

## Day to day

```bash
fail2ban-client status              # the jails
fail2ban-client status sshd         # failures and banned addresses of one jail
fail2ban-client unban 203.0.113.7   # let one address in again
fail2ban-client unban --all
nft list table inet f2b-table       # the bans as the kernel sees them
```

## Tags

`fail2ban_install`, `fail2ban_config`

## Licence

Apache License 2.0 - see [LICENSE](../../LICENSE).
