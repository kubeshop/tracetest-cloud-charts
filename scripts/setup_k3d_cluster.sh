#!/usr/bin/env bash

set -e

function show_help() {
  echo "Usage: setup_k3d_cluster.sh [OPTIONS]"
  echo "Options:"
  echo "  --reset     Reset the existing k3d cluster"
  echo "  --private   Use private repositories. Requires a PAT with read:packages scope."
  echo "  --help      Show this help message"
}

if [[ "$@" == *"--help"* ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
CLUSTER_NAME=tracetest-enterprise
SERVERS=3

if [[ "$@" == *"--reset"* ]]; then
  k3d cluster delete $CLUSTER_NAME
fi

if ! k3d cluster list | grep -q $CLUSTER_NAME; then
  k3d cluster create $CLUSTER_NAME --servers=$SERVERS
else 
  echo "Cluster already exists"
fi

if [[ "$@" == *"--private"* ]]; then
  printf "\e[41mPrivate version requested. Please provide your credentials.\e[0m\n"
  
  $PROJECT_ROOT/scripts/create_image_pull_secret.sh
fi

# install mongo operator
helm repo add mongodb https://mongodb.github.io/helm-charts --force-update
helm install \
  community-operator mongodb/community-operator 

# install cert manager
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.0 \
  --set crds.enabled=true

helm install ttdeps $PROJECT_ROOT/charts/tracetest-dependencies -f $PROJECT_ROOT/values-kind.yaml
helm install tt $PROJECT_ROOT/charts/tracetest-onprem -f $PROJECT_ROOT/values-kind.yaml

