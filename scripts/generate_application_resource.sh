#!/usr/bin/env bash

cluster_role=$1

metrics_server_chart_version=$(jq -er .metrics_server_chart_version environments/$cluster_role.json)
argocd_namespace=$(jq -er .argocd_namespace environments/$cluster_role.json)

mkdir deploy-files

# update the application.yaml with the new chart version then stage the files for writing to the app-of-app config repo
cat <<EOF > deploy-files/application.yaml
# roles/production/metrics-server/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metrics-server
  namespace: $argocd_namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: psk-aws-control-plane-configuration

  sources:
    - repoURL: https://kubernetes-sigs.github.io/metrics-server/
      chart: metrics-server
      targetRevision: $metrics_server_chart_version
      helm:
        valueFiles:
          - \$config/roles/$cluster_role/metrics-server/default-values.yaml
          - \$config/roles/$cluster_role/metrics-server/$cluster_role-values.yaml
    - repoURL: https://github.com/twplatformlabs/psk-aws-control-plane-configuration
      targetRevision: HEAD
      ref: config
  destination:
    server: https://kubernetes.default.svc
    namespace: kube-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 5
      backoff:
        duration: 30s
        factor: 2
        maxDuration: 5m
EOF

cp deploy-templates/default-values.yaml deploy-files/default-values.yaml
cp deploy-templates/$cluster_role-values.yaml deploy-files/$cluster_role-values.yaml
