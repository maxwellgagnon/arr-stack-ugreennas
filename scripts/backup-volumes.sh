#!/bin/bash
#
# Backup all Docker named volumes to a directory
# Usage: ./scripts/backup-volumes.sh [/path/to/backup/dir]
#
# Default: /volume1/backups/arr-stack-YYYYMMDD
#

set -e

BACKUP_DIR="${1:-/volume1/backups/arr-stack-$(date +%Y%m%d)}"
mkdir -p "$BACKUP_DIR"

# All named volumes used by the stack
VOLUMES=(
  # arr-stack.yml
  arr-stack_gluetun-config
  arr-stack_qbittorrent-config
  arr-stack_sonarr-config
  arr-stack_prowlarr-config
  arr-stack_radarr-config
  arr-stack_jellyfin-config
  arr-stack_jellyfin-cache
  arr-stack_jellyseerr-config
  arr-stack_bazarr-config
  arr-stack_pihole-etc-pihole
  arr-stack_pihole-etc-dnsmasq
  arr-stack_wireguard-easy-config
  # utilities.yml
  arr-stack_uptime-kuma-data
  arr-stack_duc-index
)

echo "Backing up to: $BACKUP_DIR"
echo ""

for vol in "${VOLUMES[@]}"; do
  if docker volume inspect "$vol" &>/dev/null; then
    echo "Backing up $vol..."
    docker run --rm \
      -v "$vol":/source:ro \
      -v "$BACKUP_DIR":/backup \
      alpine cp -a /source/. "/backup/${vol#arr-stack_}/"
  else
    echo "Skipping $vol (not found)"
  fi
done

echo ""
echo "Backup complete: $BACKUP_DIR"
echo ""
echo "To restore a volume:"
echo "  docker run --rm -v /path/to/backup/VOLUME_NAME:/source:ro -v arr-stack_VOLUME_NAME:/dest alpine cp -a /source/. /dest/"
