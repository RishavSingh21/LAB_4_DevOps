#!/usr/bin/env bash
# Progressive canary rollout with automatic rollback.
#   ./canary.sh                      -> healthy canary, promoted to 100%
#   CANARY_ERROR_RATE=0.5 ./canary.sh -> bad canary, rolled back at first step
set -uo pipefail
cd "$(dirname "$0")"
STEPS=(10 25 50 100); REQS=100; MAX_ERR_PCT=5
export CANARY_ERROR_RATE="${CANARY_ERROR_RATE:-0}"

set_weights() {  # $1 = canary percent
  local c=$1 s=$((100-$1)); local down=""; [ "$c" -eq 0 ] && down=" down"
  cat > nginx/conf.d/default.conf <<CONF
upstream backend {
  server app-stable:5000 weight=$s;
  server app-canary:5000 weight=$c$down;
}
server { listen 80; location / { proxy_pass http://backend; } }
CONF
  docker compose exec -T nginx nginx -s reload >/dev/null
}
metric() { curl -s localhost:8082/metrics | awk -v k="$1" '$1==k{print $2}'; }

docker compose up -d --build && sleep 5
for pct in "${STEPS[@]}"; do
  echo "== Canary at ${pct}% =="
  set_weights "$pct"
  r0=$(metric app_requests_total); e0=$(metric app_errors_total)
  for _ in $(seq 1 $REQS); do curl -s -o /dev/null localhost:8080/; done
  r1=$(metric app_requests_total); e1=$(metric app_errors_total)
  dr=$((r1-r0)); de=$((e1-e0)); pcterr=0
  [ "$dr" -gt 0 ] && pcterr=$((100*de/dr))
  echo "   canary served=$dr errors=$de error_rate=${pcterr}% (threshold ${MAX_ERR_PCT}%)"
  if [ "$pcterr" -gt "$MAX_ERR_PCT" ]; then
    echo "!! ROLLBACK TRIGGERED: error rate above threshold"
    set_weights 0
    echo "Traffic restored 100% to stable."; exit 1
  fi
done
echo "Canary healthy at every step -> PROMOTED to 100%."
