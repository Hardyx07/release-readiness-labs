# OrderFlow v2.3.0 – Release Readiness Pack

| Field | Value |
|---|---|
| Product | OrderFlow |
| Release version | **v2.3.0** |
| Previous version | v2.2.0 |
| Git tag | `v2.3.0` |
| Container image | `lab-app:v2.3.0` (also `lab-app:v2.3.0-<commit-sha>`) |
| Target environment | production |
| Release manager | Hardik Tailor |
| Release date | 2026-11-04 |
| Status | Ready for production |

---

## 1. Release version information

The version **v2.3.0** is defined once in the pipeline (`RELEASE_VERSION`) and must match:

- `app/package.json` → `"version": "2.3.0"`
- `release/release.json` → `"Version": "2.3.0"`
- `deployment/kubernetes/deployment.yaml` → `image: lab-app:v2.3.0`
- Git tag → `v2.3.0`

The validation stage fails if any of these do not match. Every image is tagged with the
version **and** the commit SHA and carries OCI labels (`image.version`, `image.revision`),
so every deployed artifact can be traced back to one commit. The `/health` endpoint
returns the running version.

## 2. Deployment strategy

- **Pipeline order:** Validate → Build versioned image + smoke test → Deploy to production.
  Each stage uses `needs:` so production cannot run unless the earlier stages pass.
- **Branch rule:** the production job only runs from `main` or a `v*` tag, never from
  feature branches or pull requests.
- **Approval:** the deploy job uses the protected GitHub environment `production`, which
  requires a reviewer to approve before it starts.
- **Kubernetes rolling update:** 3 replicas, `maxUnavailable: 0`, `maxSurge: 1`, with
  readiness and liveness probes on `/health`. New pods only receive traffic once healthy,
  so there is no downtime.
- **Concurrency:** only one deployment per branch or tag at a time.

## 3. Rollback strategy

| Item | Value |
|---|---|
| Method | `kubectl rollout undo deployment/lab-app` (Kubernetes keeps 5 old revisions) |
| Target version | v2.2.0 |
| Script | `ROLLBACK_VERSION=v2.2.0 ./scripts/rollback.sh` |
| Time limit | 5 minutes |
| Owner | Release manager |

**Roll back when:** `/health` fails after deploy, the rollout does not finish in 120 s,
or error rate / latency rises after release.

**Verify rollback:** `kubectl rollout status deployment/lab-app` succeeds and `/health`
returns version 2.2.0.

## 4. Deployment infrastructure decision

| Option | Decision | Reason |
|---|---|---|
| Single `t2.micro` EC2 instance (original) | Rejected | Free-tier/burstable size, single point of failure, no rolling update or easy rollback |
| **Kubernetes – 3 replicas on `t3.medium` nodes** | **Chosen** | High availability, self-healing, zero-downtime rolling updates, one-command rollback, native Secrets |

Terraform now takes instance type, node count and AMI as variables, tags every node with
`Environment=production` and `Version=v2.3.0`, and has no hardcoded credentials.

## 5. Production approval checklist

- [x] Validation stage passed (tests, version check, secret scan)
- [x] Versioned Docker image built and smoke tested
- [x] No hardcoded secrets in the repository
- [x] Secrets stored in GitHub `production` environment secrets
- [x] Kubernetes uses `secretKeyRef` instead of plain-text values
- [x] Terraform secret variable marked `sensitive`, no default
- [x] Image tag is immutable (`v2.3.0`), not `latest` / `production-build`
- [x] `production` environment requires reviewer approval
- [x] Production deploy restricted to `main` and `v*` tags
- [x] Rollback plan and script reviewed
- [x] Infrastructure decision reviewed
- [x] Release approved by release manager (`release/approvals.yml`)

## 6. Deployment validation summary

| Check | Stage | Result |
|---|---|---|
| Unit tests (`npm test`) | 1 – Validate | Passed |
| Version consistency (workflow / package.json / release.json / k8s / tag) | 1 – Validate | Passed |
| Hardcoded secret scan | 1 – Validate | Passed |
| Docker image build `lab-app:v2.3.0` | 2 – Build | Passed |
| Smoke test `GET /health` returns version 2.3.0 | 2 – Build | Passed |
| Manual approval (production environment) | 3 – Deploy | Approved |
| Production deploy | 3 – Deploy | Passed |

Evidence: GitHub → Actions → **Release Pipeline** → run for `main` / tag `v2.3.0` (all three stages green).

## Issues found and fixed

| # | File | Problem | Fix |
|---|---|---|---|
| 1 | `.github/workflows/release.yml` | Deploy ran **before** validation | Order is now validate → build → deploy using `needs:` |
| 2 | `.github/workflows/release.yml` | Validation always failed (`exit 1`) | Removed; real checks added |
| 3 | `.github/workflows/release.yml` | No approval / environment protection | `environment: production` with required reviewer |
| 4 | `.github/workflows/release.yml` | No version referenced, old `checkout@v3` | `RELEASE_VERSION: v2.3.0`, `checkout@v4` |
| 5 | `scripts/deploy.sh` | Deployed `latest` | Uses `RELEASE_VERSION`, fails if missing |
| 6 | `scripts/rollback.sh` | Empty | Real rollback steps |
| 7 | `deployment/kubernetes/deployment.yaml` | Plain-text API key and DB password | `secretKeyRef` to `lab-app-secrets` |
| 8 | `deployment/kubernetes/deployment.yaml` | Untraceable tag `production-build` | `lab-app:v2.3.0`, probes, rolling update |
| 9 | `release/deployment-config.yml` | Hardcoded secrets, untraceable tag | Placeholders only, tag `v2.3.0` |
| 10 | `deployment/terraform/variables.tf` | Secret with default value | `sensitive = true`, no default |
| 11 | `deployment/terraform/main.tf` | Single `t2.micro`, hardcoded AMI | 3 × `t3.medium` nodes, variables, tags |
| 12 | `app/package.json`, `release/release.json` | Versions 1.0.0 / 1.0 | 2.3.0 |
| 13 | `release/approvals.yml`, `rollback.yml`, `release-summary.yml` | Empty / `latest` / `none` | Completed |
| 14 | `Dockerfile` | Node 18 (end of life), runs as root | Node 20, `USER node`, version label |
| 15 | `.gitignore` | Terraform state could be committed | Ignores `*.tfstate`, `.terraform/`, `*.tfvars` |
