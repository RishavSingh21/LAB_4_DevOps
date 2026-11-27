#!/usr/bin/env bash
# FAILOVER drill: disaster -> restore on DR site -> measure RTO/RPO
set -euo pipefail
cd "$(dirname "$0")"
docker compose up -d && sleep 8
./backup.sh
LAST=$(ls -t backups/*.sql | head -1)
echo "Simulating post-backup writes (these would be LOST => RPO)..."
docker compose exec -T db-primary psql -U postgres -d shop -c "INSERT INTO orders(item) VALUES ('late-1'),('late-2');" >/dev/null
PRIMARY_ROWS=$(docker compose exec -T db-primary psql -U postgres -d shop -tAc 'select count(*) from orders')
echo "### DISASTER: stopping primary ###"
START=$(date +%s)
docker compose stop db-primary
./restore.sh "$LAST"
END=$(date +%s)
STANDBY_ROWS=$(docker compose exec -T db-standby psql -U postgres -d shop -tAc 'select count(*) from orders')
echo "-------- RESULTS --------"
echo "RTO (measured):       $((END-START)) s  (target: <= 60 s)"
echo "Rows lost (RPO):      $((PRIMARY_ROWS-STANDBY_ROWS)) rows written after last backup (target RPO: backup interval)"
echo "Service on standby:   port 5434 (psql -h localhost -p 5434 -U postgres shop)"
