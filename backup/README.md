# Backup

## Automated Backups

The `homelab-backup.timer` runs every Sunday at midnight. It backs up all Podman volumes labeled `homelab=<service>` across all users, encrypts them with GPG, and stores them under `/mnt/backup/<hostname>/`.

Check timer status:

```bash
systemctl list-timers homelab-backup.timer
```

View logs from the last backup run:

```bash
journalctl -u homelab-backup.service
```

## Manual Backup

Trigger a backup immediately:

```bash
sudo systemctl start homelab-backup.service
```

Backups are saved to `/mnt/backup/<hostname>/` with the naming format:

```
<user>_<volume>_<YYYY-MM-DD_HH-MM-SS>.tar.gz.gpg
```

## Restore

Restore a volume from an encrypted backup:

```bash
sudo homelab-restore.sh /mnt/backup/<hostname>/<user>_<volume>_<YYYY-MM-DD_HH-MM-SS>.tar.gz.gpg
```

The script parses the user and volume name from the filename, stops any containers using the volume, decrypts and imports the backup, then restarts the containers.

## Retention

By default, the 4 most recent backups are kept per volume. Older backups are automatically deleted after each run. This is configurable via `backup_retention` in `group_vars/servers.yml`.
