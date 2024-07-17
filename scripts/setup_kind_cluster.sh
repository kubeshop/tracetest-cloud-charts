#!/usr/bin/env bash

set -e

function show_help() {
  echo "Usage: setup_kind_cluster.sh [OPTIONS]"
  echo "Options:"
  echo "  --reset      Reset the existing kind cluster"
  echo "  --private    Use private repositories. Requires a PAT with read:packages scope."
  echo "  --build-deps Build dependencies for all charts"
  echo "  --help       Show this help message"
}

if [[ "$@" == *"--help"* ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
KUBECONFIG_FILE=$(pwd)/tracetest.kubeconfig
ENV_FILE=$PROJECT_ROOT/cluster.env

SETUP_CLUSTER=false

if [[ "$@" == *"--reset"* ]]; then
  printf "\n\e[41m\e[1mDeleting existing cluster\e[0m\e[0m\n"
  kind delete cluster --name tracetest
fi

if ! kind get clusters | grep -q tracetest; then
  printf "\n\e[42m\e[1mCreate new cluster\e[0m\e[0m\n"
  SETUP_CLUSTER=true
  kind create cluster \
    --name tracetest \
    --config $PROJECT_ROOT/kind-config.yaml \
    --kubeconfig $KUBECONFIG_FILE
else 
  printf "\e[1mCluster already exists\e[0m\n"
fi

cat <<EOF > $ENV_FILE
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_FILE
kubectl config use-context kind-tracetest
EOF

source $ENV_FILE

if [[ "$SETUP_CLUSTER" == true ]]; then
  if [[ "$@" == *"--private"* ]]; then
    printf "\n\e[41mPrivate version requested. Please provide your credentials.\e[0m\n"
    
    $PROJECT_ROOT/scripts/create_image_pull_secret.sh
  fi

  # install cert manager
  helm repo add jetstack https://charts.jetstack.io --force-update
  helm upgrade --install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.15.0 \
    --set crds.enabled=true
fi

if [[ "$@" == *"--build-deps"* ]]; then
  for dir in $PROJECT_ROOT/charts/*; do
    if [[ -d "$dir" ]]; then
      echo "Building dependencies for $dir"
      helm dependency build "$dir"
    fi
  done
fi

echo "Starting Tracetest OnPrem installation on Kind"

helm upgrade --install ttdeps $PROJECT_ROOT/charts/tracetest-dependencies -f $PROJECT_ROOT/values-kind.yaml
helm upgrade --install tt $PROJECT_ROOT/charts/tracetest-onprem -f $PROJECT_ROOT/values-kind.yaml

if [[ "$@" == *"--install-demo"* ]]; then
  helm upgrade --install ttdemo -n demo --create-namespace $PROJECT_ROOT/charts/pokeshop-demo -f $PROJECT_ROOT/values-kind-demo.yaml
fi

printf "\e[42m\e[1mConfiguring CoreDNS\e[0m\e[0m\n"
$PROJECT_ROOT/scripts/coredns_config.sh ttdeps-traefik.default.svc.cluster.local tracetest.localdev pokeshop.localdev