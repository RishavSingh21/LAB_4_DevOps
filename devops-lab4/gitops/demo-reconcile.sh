#!/usr/bin/env bash
# Demonstrates drift detection + self-heal (Git = single source of truth).
echo "Replicas in Git: 2.  Manually scaling to 5 (drift)..."
kubectl -n demo scale deploy/demo-app --replicas=5
sleep 2; kubectl -n demo get deploy demo-app
echo "Waiting for Argo CD self-heal..."; sleep 30
kubectl -n demo get deploy demo-app    # back to 2
echo "Now change replicas in Git, push, and watch Argo CD sync it automatically."
