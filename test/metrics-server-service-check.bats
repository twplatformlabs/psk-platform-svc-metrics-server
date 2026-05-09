#!/usr/bin/env bats

@test "metrics-server status is Running" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "endpoint returns architectural context info, running on arm64" {
  run bash -c "kubectl get --raw '/apis/metrics.k8s.io/v1beta1/nodes'"
  [[ "${output}" =~ "kubernetes.io/arch" ]]
  [[ "${output}" =~ "arm64" ]]
}