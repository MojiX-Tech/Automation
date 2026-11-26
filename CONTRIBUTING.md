# Contributing

Bug reports, questions and pull requests are welcome.

## Reporting a bug

Open an issue and say which role and version, which OS the target runs, what you expected and
what happened. The output of the failing task helps most.

## Changing a role

Every role lives in `roles/<name>/` and is changed only here. The repositories
`ansible-role-<name>` are written by the releases of this one.

Rules that every role follows:

- **Safe defaults.** A role run with no variables set must be right for an ordinary server.
- **Say what you change.** The README of a role lists everything it changes on the host.
- **Stand alone.** A role does not name or need another role of this repository.
- **Debian and Ubuntu.** The newest release and the two before it.
- **A second run changes nothing.**

## Checks

The same checks run on GitHub for every push and pull request:

```bash
pip install ansible-core ansible-lint yamllint
yamllint .
ansible-lint
```

The tests boot a virtual machine per OS version, run the role twice and then run
`tests/verify-<role>.sh` on the machine. A change of a role's behaviour needs a matching check
in that script. A new variable also goes into `meta/argument_specs.yml` and the README table.

## Releases

The version is in `galaxy.yml`, the changes in `CHANGELOG.md`. A tag `v<version>` publishes
the collection and every changed role to Ansible Galaxy.
