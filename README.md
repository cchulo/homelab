# Homelab

Ansible playbooks for setting up home servers and workstations.

## Prerequisites

- Ansible with the `ansible.posix` collection
- `firewalld` running on target servers
- SSH access to all hosts

```bash
ansible-galaxy collection install ansible.posix
```

## Inventory

Copy `inventory.ini.example` to `inventory.ini` and fill in the information for your servers and workstations

## Vault

Server variables are stored in `group_vars/servers.yml`, encrypted with Ansible Vault.

```bash
# Edit the vault
ansible-vault edit group_vars/servers.yml

# View the vault
ansible-vault view group_vars/servers.yml
```

Copy `group_vars/servers.yml.example` to `group_vars/servers.yml`, fill in your values, then encrypt:

```bash
ansible-vault encrypt group_vars/servers.yml
```

## Usage

```bash
# Deploy everything
ansible-playbook -Ki inventory.ini --ask-vault-pass up.yaml

# Tear down everything
ansible-playbook -Ki inventory.ini --ask-vault-pass down.yaml

# Servers only
ansible-playbook -Ki inventory.ini --ask-vault-pass up.yaml --limit servers

# SteamOS only
ansible-playbook -Ki inventory.ini up.yaml --limit steamos

# Single service
ansible-playbook -Ki inventory.ini --ask-vault-pass nginx/up.yaml
ansible-playbook -Ki inventory.ini --ask-vault-pass forgejo/up.yaml
ansible-playbook -Ki inventory.ini --ask-vault-pass netbootxyz/up.yaml
ansible-playbook -Ki inventory.ini steamos/up.yaml
```

The `-K` flag prompts for the become (sudo) password, required for firewalld operations on servers. The `--ask-vault-pass` flag prompts for the Ansible Vault password to decrypt secrets.

## Structure

```
├── common/
│   ├── tasks.up.yaml       # shared deploy logic (quadlets, firewall, systemd)
│   └── tasks.down.yaml     # shared teardown logic
├── backup/                 # NFS mount + encrypted volume backup service
├── network/                # homelab podman network + firewall port forwards
├── nginx/                  # Nginx Proxy Manager
├── forgejo/                # Forgejo git server
├── netbootxyz/             # netboot.xyz PXE boot server
├── cockpit/                # Cockpit web console + libvirt
├── steamos/                # SteamOS workstation config
├── group_vars/
│   └── servers.yml         # server variables (encrypted with Ansible Vault)
├── inventory.ini.example
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
