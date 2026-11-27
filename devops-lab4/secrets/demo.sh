#!/usr/bin/env bash
cd "$(dirname "$0")"
export DEMO_DB_PASSWORD="$(openssl rand -hex 12)"   # generated at runtime, never committed
docker compose up -d --build && sleep 10
echo "--- App reads secret from Vault, returns it MASKED:"
curl -s localhost:5000/secret-check; echo
echo "--- Secret exists in vault (admin view):"
docker compose exec -T -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=dev-root-token vault vault kv get secret/devops-lab4
echo "--- Proof no secret in repo/image:"
git -C .. grep -n "DB_PASSWORD=" -- . ':!secrets' ':!app/tests' || echo "none found in tracked code"
