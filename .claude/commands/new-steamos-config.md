Add a new SteamOS configuration to this homelab project.

Ask the user for:
1. What the config is for (e.g. `wireplumber`, `gtk`, `environment`)
2. The destination path on the SteamOS device (e.g. `~/.config/wireplumber/wireplumber.conf.d/`)
3. The config file name and contents

Then:

1. Create the config file at `steamos/<config-type>/<filename>`

2. Add to `steamos/up.yaml` under `tasks:`:
```yaml
- name: Create <config-type> config directory
  ansible.builtin.file:
    path: "{{ ansible_env.HOME }}/<destination-dir>"
    state: directory
    mode: "0755"

- name: Copy <config-type> config
  ansible.builtin.copy:
    src: "{{ playbook_dir }}/<config-type>/<filename>"
    dest: "{{ ansible_env.HOME }}/<destination-dir>/<filename>"
    mode: "0644"
```

3. Add to `steamos/down.yaml` under `tasks:`:
```yaml
- name: Remove <config-type> config
  ansible.builtin.file:
    path: "{{ ansible_env.HOME }}/<destination-dir>/<filename>"
    state: absent
```

Reminders:
- SteamOS tasks never use `become: true`
- No firewalld, no quadlets, no systemd user services
- `hosts: steamos` is already set at the play level
