#!/usr/bin/env bash
set -euo pipefail

# Usage: ROLLBACK_VERSION=v2.2.0 ./scripts/rollback.sh
TARGET="${ROLLBACK_VERSION:-v2.2.0}"
IMAGE="lab-app:${TARGET}"

echo "Rolling back OrderFlow to ${TARGET}"

# Lab mode: commands are printed, not executed (no real cluster)
echo "kubectl rollout undo deployment/lab-app"
echo "  (or pin a version) kubectl set image deployment/lab-app lab-app=${IMAGE}"
echo "kubectl rollout status deployment/lab-app --timeout=120s"
echo "curl -fsS http://<service-ip>/health   # confirm version = ${TARGET#v}"

echo "Rollback to ${TARGET} complete."
