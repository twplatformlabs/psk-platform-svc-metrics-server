#!/usr/bin/env bash
set -euo pipefail
source bash-functions.sh

# the argocd core reconciliation loop runs every 3min
sleep 240

cluster=$1
cluster_role=$2
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)
metrics_server_chart_version=$(jq -er .metrics_server_chart_version environments/$cluster_role.json)

# confirm new version has been synced
validate_argocore_helm_app_resource "$argocd_namespace" "metrics-server" "$metrics_server_chart_version"

# run basic smoketest for service health
bats test/metrics-server-service-check.bats

# Files that will be applied
TEST_FILES=("test/hpa-test-deployment.yaml" "test/hpa-test-load-generator.yaml")
cleanup() {
  echo "Deleting test files..."
  for f in "${TEST_FILES[@]}"; do
    kubectl delete -f "$f" --ignore-not-found=true
    echo "  removed: $f"
  done
}
trap cleanup EXIT INT TERM

# run horizontalpodautoscaler test to confirm metrics-server working health
kubectl apply -f test/hpa-test-deployment.yaml
sleep 30
kubectl apply -f test/hpa-test-load-generator.yaml
sleep 120

replicas=$(kubectl get deployment -n psk-system php-apache -o jsonpath='{.status.readyReplicas}')
echo "hpa reports $replicas replicas"

if [[ "$replicas" > 1 ]]; then
  echo "✓ PASS: hpa-test replicas scaled under load."
  EXIT_CODE=0
else
  echo "✗ FAIL: hpa-test replicas not scaling under load."
  EXIT_CODE=1
fi
exit $EXIT_CODE
