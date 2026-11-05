#!/usr/bin/env bash
set -euo pipefail

# Release version comes from the pipeline - never "latest"
VERSION="${RELEASE_VERSION:?RELEASE_VERSION is not set}"
IMAGE="lab-app:${VERSION}"

# Secrets are injected by GitHub Actions (production environment secrets)
: "${API_KEY:?API_KEY secret is missing}"
: "${DATABASE_PASSWORD:?DATABASE_PASSWORD secret is missing}"

echo "Starting deployment of OrderFlow ${VERSION}"
echo "Image:  ${IMAGE}"
echo "Commit: ${GITHUB_SHA:-local}"

# Lab mode: commands are printed, not executed (no real cluster)
echo "kubectl create secret generic lab-app-secrets --from-literal=API_KEY=*** --from-literal=DATABASE_PASSWORD=*** --dry-run=client -o yaml | kubectl apply -f -"
echo "kubectl apply -f deployment/kubernetes/"
echo "kubectl set image deployment/lab-app lab-app=${IMAGE}"
echo "kubectl rollout status deployment/lab-app --timeout=120s"

echo "Deployment of ${VERSION} successful."
