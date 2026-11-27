# Advanced Deployment Strategies Report
**Name / Roll no:**  **Date:**

## 1. Introduction
Service, goals, tools (Docker, nginx, GitHub Actions, Argo CD, Vault, PostgreSQL).

## 2. Comparison
| Criterion | Blue-Green | Canary | GitOps | Secret Mgmt (Vault) | Disaster Recovery |
|---|---|---|---|---|---|
| Purpose | Instant switch between 2 envs | Gradual exposure to real users | Git as source of truth | Protect credentials | Restore after failure |
| Downtime | None (reload) | None | None | n/a | RTO = measured __ s |
| Rollback speed | Seconds (switch back) | Seconds (weight→0), automatic | `git revert` | Rotate / revoke | Restore from backup |
| Resource cost | High (2× envs) | Low–medium | Low | Low | Medium (standby site) |
| Blast radius | All users at switch | 10% → 100% | Per-commit, auditable | Per-secret | Per-incident |
| Complexity | Low | Medium | Medium | Medium | Medium–High |

## 3. Risk Analysis
| Risk | Strategy | Likelihood | Impact | Mitigation observed |
|---|---|---|---|---|
| DB schema incompatible between blue/green | Blue-Green | M | H | Backward-compatible migrations |
| Canary too small to detect errors | Canary | M | M | Min request volume per step |
| Config drift / manual changes | GitOps | M | M | selfHeal reverted drift (evidence) |
| Leaked credentials | Secrets | L | H | Vault + gitleaks gate |
| Backup stale / untested | DR | M | H | Scheduled backups + drills |

## 4. Evidence
Paste screenshots with captions: blue-green log, canary promote/rollback, Argo CD sync, Vault masked output, DR RTO/RPO, CI gates.

## 5. Advantages & Limitations (per strategy)
- **Blue-Green:** + zero-downtime, instant rollback; − double cost, shared-DB/state problems.
- **Canary:** + limited blast radius, data-driven; − needs metrics/traffic, slower, version coexistence.
- **GitOps:** + audit trail, reproducible, self-healing; − Git is critical dependency, secrets need extra tooling.
- **Secrets:** + central, auditable, rotation; − Vault itself needs HA/unsealing.
- **DR:** + business continuity; − cost, RPO gap between backups.

## 6. Conclusions
Recommended combined workflow: CI gates → image → Git commit (GitOps) → canary → promote (or blue-green for DB-light apps); secrets from Vault; DR drills quarterly. State actual measured RTO/RPO and canary results.
