# Homelab
Ansible playbooks for setting up my various servers and workstations at home.

## Prerequisites

- Ansible with the `ansible.posix` collection
- `firewalld` running on target servers
- SSH access to all hosts

```bash
ansible-galaxy collection install ansible.posix
```

## Inventory

Edit `inventory.ini` with your actual hosts:

```ini
[servers]
my-server ansible_host=192.168.1.x ansible_user=cchulo

[steamos]
steamdeck ansible_host=192.168.1.x ansible_user=deck
```

## Usage

```bash
# Deploy everything
ansible-playbook -Ki inventory.ini up.yaml

# Tear down everything
ansible-playbook -Ki inventory.ini down.yaml

# Servers only
ansible-playbook -Ki inventory.ini up.yaml --limit servers

# SteamOS only
ansible-playbook -Ki inventory.ini up.yaml --limit steamos

# Single service
ansible-playbook -Ki inventory.ini nginx/up.yaml
ansible-playbook -Ki inventory.ini forgejo/up.yaml
ansible-playbook -Ki inventory.ini netbootxyz/up.yaml
ansible-playbook -Ki inventory.ini steamos/up.yaml
```

The `-K` flag prompts for the become (sudo) password, required for firewalld operations on servers.

## Structure

```
├── common/
│   ├── tasks.up.yaml       # shared deploy logic (quadlets, firewall, systemd)
│   └── tasks.down.yaml     # shared teardown logic
├── network/                # homelab podman network + firewall port forwards
├── nginx/                  # Nginx Proxy Manager
├── forgejo/                # Forgejo git server
├── netbootxyz/             # netboot.xyz PXE boot server
├── steamos/                # SteamOS workstation config
├── inventory.ini
├── up.yaml                 # deploys all services
└── down.yaml               # tears down all services
```

Each service directory contains:
- `up.yaml` / `down.yaml` — playbook for that service
- `systemd/` — Podman quadlet files (servers only)

Quadlets run as rootless Podman under the user's systemd session. Firewall rules require sudo.

## Firewall port forwards (servers)

| External | Internal | Purpose |
|----------|----------|---------|
| 80/tcp   | 8080/tcp | Nginx HTTP |
| 443/tcp  | 8443/tcp | Nginx HTTPS |
| 69/udp   | 8069/udp | netboot.xyz TFTP |

## Services

### Nginx Proxy Manager
Web UI: `http://server:8080` / `https://server:8443`
Admin UI: `http://server:8081`

### Forgejo
Web UI: `http://server:3000`
SSH: `server:3022`

### netboot.xyz
Web UI: `http://server:3001`
TFTP: `server:8069` (UDP)
Assets: `http://server:8082`
