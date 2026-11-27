#!/usr/bin/env bash
# Usage: ./switch.sh green|blue   -> graceful nginx reload = zero downtime
set -euo pipefail
cd "$(dirname "$0")"
TARGET="${1:?usage: switch.sh blue|green}"
[[ "$TARGET" =~ ^(blue|green)$ ]] || { echo "must be blue or green"; exit 1; }
# health-check the target BEFORE switching
docker compose exec -T nginx wget -qO- "http://app-$TARGET:5000/health" >/dev/null \
  || { echo "app-$TARGET unhealthy, aborting switch"; exit 1; }
sed -i -E "s#proxy_pass http://app-(blue|green):5000#proxy_pass http://app-$TARGET:5000#" nginx/conf.d/default.conf
docker compose exec -T nginx nginx -t
docker compose exec -T nginx nginx -s reload
echo "Traffic now routed to: $TARGET"
