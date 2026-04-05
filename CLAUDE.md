# Homelab Project Rules

## Structure

This project uses per-service Ansible playbooks modeled after chadweimer/quadlets.

```
servers/
└── <service>/
    ├── up.yaml              # deploy playbook
    ├── down.yaml            # teardown playbook
    └── systemd/             # Podman quadlet files
        ├── <service>.container
        ├── <service>.image
        └── <service>-<name>.volume
steamos/
├── up.yaml
├── down.yaml
└── <config-type>/       # e.g. wireplumber/
    └── <config-file>
common/
├── tasks.up.yaml        # shared server deploy logic
└── tasks.down.yaml      # shared server teardown logic
```

## Host groups

- `servers` — homelab servers running rootless Podman quadlets
- `steamos` — SteamOS workstations (no Podman, no firewalld)

## Adding a new server service

Use `/new-server-service` or follow these rules:

1. Create `servers/<service>/systemd/` with quadlet files (`.container`, `.image`, `.volume` as needed)
2. Create `servers/<service>/up.yaml` with `hosts: servers`, import `../../common/tasks.up.yaml`, and pass `fw_services` and `systemd_services` vars
3. Create `servers/<service>/down.yaml` with `hosts: servers`, import `../../common/tasks.down.yaml`, and pass `systemd_services` vars
4. Add `- ansible.builtin.import_playbook: servers/<service>/up.yaml` to root `up.yaml`
5. Add `- ansible.builtin.import_playbook: servers/<service>/down.yaml` to root `down.yaml` (in reverse order)

### Quadlet volume conventions

- Always add `Label=homelab=<service>` to every `.volume` file

### Quadlet container conventions

- Always include `After=network-online.target` in `[Unit]`
- Always attach to `Network=homelab`
- Always set `Environment="TZ=America/Los_Angeles"`
- Reference image via `Image=<service>.image` (not direct image URL)
- Set `Restart=always` in `[Service]`

### Firewall vars format

```yaml
fw_services:
  to_create:
    - name: <service>
      ports:
        - 8080/tcp
        - 9000/udp
  to_enable:
    - <service>
```

## Adding a new SteamOS config

Use `/new-steamos-config` or follow these rules:

1. Add config file(s) under `steamos/<config-type>/`
2. Add tasks to `steamos/up.yaml` to create the destination directory and copy the file
3. Add the corresponding removal task to `steamos/down.yaml`
4. SteamOS uses `hosts: steamos` — no `become`, no firewalld, no quadlets

## General rules

- Always use `ansible_env.HOME` and `ansible_user_id` for remote paths/ownership — never `lookup('env', 'HOME')` or `lookup('env', 'USER')`, which resolve on the controller, not the remote host

- Never commit `inventory.ini` — it is gitignored
- Port forwards (80→8080, 443→8443, 69→8069) live in `servers/network/up.yaml`
- The `homelab.network` quadlet lives in `servers/network/systemd/`
- `down.yaml` imports services in reverse order of `up.yaml`
