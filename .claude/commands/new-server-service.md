Add a new server service to this homelab project.

Ask the user for:
1. Service name (e.g. `jellyfin`)
2. Docker image (e.g. `docker.io/jellyfin/jellyfin:latest`)
3. Ports to expose (host:container, with protocol if UDP)
4. Volumes needed (volume-name:container-path)
5. Any extra environment variables beyond TZ

Then create all of the following files:

**`<service>/systemd/<service>.image`**
```
[Image]
Image=<image>
Policy=always
```

**`<service>/systemd/<service>.container`**
```
[Unit]
Description=<service> container
Requires=<volumes...> homelab.network
After=network-online.target <volumes...> homelab.network

[Container]
Environment="TZ=America/Los_Angeles"
Image=<service>.image
ContainerName=<service>
PublishPort=<host>:<container>
Volume=<volume-name>:<container-path>
Network=homelab

[Service]
Restart=always

[Install]
WantedBy=default.target
```

**`<service>/systemd/<service>-<name>.volume`** (one per volume)
```
[Volume]
VolumeName=<volume-name>
Label=homelab=<service>

[Install]
WantedBy=default.target
```

**`<service>/up.yaml`**
```yaml
- name: Bring up <service>
  hosts: servers

  tasks:
    - name: Bring up service
      ansible.builtin.import_tasks: ../common/tasks.up.yaml
      vars:
        fw_services:
          to_create:
            - name: <service>
              ports:
                - <port>/tcp
          to_enable:
            - <service>
        systemd_services:
          - <service>.service
```

**`<service>/down.yaml`**
```yaml
- name: Bring down <service>
  hosts: servers

  tasks:
    - name: Bring down service
      ansible.builtin.import_tasks: ../common/tasks.down.yaml
      vars:
        systemd_services:
          - <service>.service
```

Then update:
- `up.yaml` — append `- ansible.builtin.import_playbook: <service>/up.yaml`
- `down.yaml` — prepend `- ansible.builtin.import_playbook: <service>/down.yaml` (before other service teardowns, after network)
