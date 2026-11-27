#!/usr/bin/env bash
# BACKUP: timestamped logical dump of primary
set -euo pipefail
cd "$(dirname "$0")"; mkdir -p backups
F="backups/shop-$(date +%Y%m%d-%H%M%S).sql"
docker compose exec -T db-primary pg_dump -U postgres shop > "$F"
echo "Backup created: $F ($(wc -l < "$F") lines)"
