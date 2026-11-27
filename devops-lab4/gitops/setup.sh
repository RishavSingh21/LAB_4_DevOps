#!/usr/bin/env bash
# Needs: docker, kind, kubectl. Creates a local cluster with Argo CD.
set -euo pipefail
cd "$(dirname "$0")/.."
kind create cluster --name lab4 || true
docker build -t devops-lab4-app:1.0.0 app
kind load docker-image devops-lab4-app:1.0.0 --name lab4
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl apply -f gitops/argocd/application.yaml
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
echo "UI: kubectl -n argocd port-forward svc/argocd-server 8443:443  -> https://localhost:8443"
