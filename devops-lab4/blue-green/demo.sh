#!/usr/bin/env bash
# Proves zero downtime: hammers the endpoint while switching blue -> green -> blue (rollback).
cd "$(dirname "$0")"
docker compose up -d --build && sleep 5
fail=0; : > /tmp/bg.log
( for i in $(seq 1 300); do
    out=$(curl -s -o /dev/null -w "%{http_code}" localhost:8080/ ) || out=000
    ver=$(curl -s localhost:8080/ | grep -o '"color":"[a-z]*"' || true)
    echo "$(date +%T) $out $ver" >> /tmp/bg.log; sleep 0.1
  done ) &
LOOP=$!
sleep 8;  ./switch.sh green
sleep 8;  ./switch.sh blue   # instant rollback
wait $LOOP
echo "Total requests: $(wc -l < /tmp/bg.log)  Non-200: $(grep -vc ' 200 ' /tmp/bg.log || true)"
echo "See /tmp/bg.log (screenshot this for evidence)"
