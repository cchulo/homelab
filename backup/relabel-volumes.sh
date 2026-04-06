#!/usr/bin/env bash
set -euo pipefail

# One-time helper script to recreate Podman volumes with their homelab labels.
# Run as the user who owns the volumes (not root).
#
# Usage: ./relabel-volumes.sh

QUADLET_DIR="${HOME}/.config/containers/systemd"

if [[ ! -d "$QUADLET_DIR" ]]; then
    echo "No quadlet directory found at $QUADLET_DIR"
    exit 1
fi

for volume_file in "$QUADLET_DIR"/*.volume; do
    [[ -f "$volume_file" ]] || continue

    volume_name=$(grep -Po '(?<=^VolumeName=).*' "$volume_file") || continue
    label=$(grep -Po '(?<=^Label=).*' "$volume_file") || continue

    # Check if volume exists
    if ! podman volume exists "$volume_name" 2>/dev/null; then
        echo "SKIP: Volume $volume_name does not exist"
        continue
    fi

    # Check if label is already applied
    existing_labels=$(podman volume inspect "$volume_name" --format '{{.Labels}}')
    if [[ "$existing_labels" != "map[]" ]]; then
        echo "SKIP: Volume $volume_name already has labels: $existing_labels"
        continue
    fi

    echo "Relabeling volume: $volume_name (label: $label)"

    # Find and stop containers using this volume
    containers=$(podman ps --filter "volume=$volume_name" --format '{{.Names}}' 2>/dev/null) || true
    stopped_units=()
    while IFS= read -r container; do
        [[ -z "$container" ]] && continue
        unit="${container}.service"
        if systemctl --user stop "$unit" 2>/dev/null; then
            stopped_units+=("$unit")
            echo "  Stopped $unit"
        fi
    done <<< "$containers"

    # Export volume data
    tmpfile=$(mktemp /tmp/volume-export-XXXXXX.tar)
    echo "  Exporting to $tmpfile"
    podman volume export "$volume_name" -o "$tmpfile"

    # Remove and recreate with label
    podman volume rm "$volume_name"
    podman volume create --label "$label" "$volume_name"

    # Import data back
    podman volume import "$volume_name" "$tmpfile"
    rm -f "$tmpfile"
    echo "  Recreated with label"

    # Restart stopped containers
    for unit in "${stopped_units[@]}"; do
        systemctl --user start "$unit" 2>/dev/null && echo "  Restarted $unit"
    done

    echo "  Done"
done

echo "Relabeling complete"
