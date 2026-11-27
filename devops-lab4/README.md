# Lab 4: Advanced Deployment Strategies & Enterprise DevOps

One small Flask service (`app/`) is used to demonstrate all 7 lab questions.

| Q | Topic | Folder | Run |
|---|-------|--------|-----|
| 1 | Disaster recovery (backup/restore/failover) | `dr/` | `make dr` |
| 2 | Automated testing in CI/CD with gates | `.github/workflows/ci.yml`, `app/tests/` | push to GitHub / `make test` |
| 3 | Blue-Green (zero downtime) | `blue-green/` | `make bluegreen` |
| 4 | GitOps (Argo CD) | `gitops/` | `make gitops` |
| 5 | Strategies report | `docs/REPORT.md` | fill in with your evidence |
| 6 | Secret management (Vault) | `secrets/` | `make secrets` |
| 7 | Canary + auto-rollback | `canary/` | `make canary` / `make canary-bad` |

**Prereqs:** Docker + Docker Compose v2, bash, curl. GitOps also needs `kind` and `kubectl`.

## Evidence to screenshot / upload per question
1. **DR:** terminal output of `make dr` (backup file, RTO, rows lost) + `dr/*.sh`.
2. **CI/CD:** GitHub Actions run showing lint → unit → integration → build → deploy; also a failed run (break a test) proving the gate blocks deploy.
3. **Blue-Green:** `make bluegreen` output (`Non-200: 0`) and `/tmp/bg.log` showing blue → green → blue.
4. **GitOps:** Argo CD UI "Synced/Healthy"; `demo-reconcile.sh` output showing drift 5 → healed to 2; Git commit that changed state.
5. **Report:** `docs/REPORT.md` exported to PDF/DOCX.
6. **Secrets:** `make secrets` output (masked response, Vault entry, gitleaks job green).
7. **Canary:** `make canary` (promoted) and `make canary-bad` (rollback triggered) outputs.

## Setup
```bash
git init && git add . && git commit -m "Lab 4"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/devops-lab4.git
git push -u origin main
```
Edit `repoURL` in `gitops/argocd/application.yaml` to your repo before running `make gitops`.

> Vault runs in **dev mode** (root token, in-memory) for the lab only. Never do this in production.
