#!/usr/bin/env bash
# RESTORE: load latest (or given) backup into the standby DB
set -euo pipefail
cd "$(dirname "$0")"
F="${1:-$(ls -t backups/*.sql | head -1)}"
docker compose exec -T db-standby psql -U postgres -d shop -c "DROP TABLE IF EXISTS orders;" >/dev/null
docker compose exec -T db-standby psql -U postgres -d shop < "$F" >/dev/null
echo "Restored $F into standby; rows: $(docker compose exec -T db-standby psql -U postgres -d shop -tAc 'select count(*) from orders')"
