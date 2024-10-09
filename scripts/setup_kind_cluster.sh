#!/usr/bin/env bash

set -e

function show_help() {
  echo "Usage: setup_kind_cluster.sh [OPTIONS]"
  echo "Options:"
  echo "  --reset              Reset the existing kind cluster"
  echo "  --private            Use private repositories. Requires a PAT with read:packages scope."
  echo "  --build-deps         Build dependencies for all charts"
  echo "  --install-demo       Install the Pokeshop demo"
  echo "  --debug              Enable Helm debug output"
  echo "  --config-coredns     Configure CoreDNS with custom records"
  echo "  --help               Show this help message"
  echo ""
  echo "Environment variables that might be read:"
  echo "  TRACETEST_LICENSE    OnPrem license key (if not provided, the script will prompt for it)"
}

if [[ "$@" == *"--help"* ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
KUBECONFIG_FILE=$PROJECT_ROOT/tracetest.kubeconfig
ENV_FILE=$PROJECT_ROOT/cluster.env
HELM_EXTRA_FLAGS=()

if [[ "$@" == *"--debug"* ]]; then
  set -x
  HELM_EXTRA_FLAGS+=(--debug)
fi

# Capturing the start time
start_time=$(date +%s)

printf "\n\e[42m\e[1mStarting cluster setup...\e[0m\e[0m\n"

if [[ "$@" == *"--build-deps"* ]]; then
  printf "\n\e[42m\e[1mBuilding dependencies for tracetest-dependencies\e[0m\e[0m\n"
  helm dependency update "$PROJECT_ROOT/charts/tracetest-dependencies"

  printf "\n\e[42m\e[1mBuilding dependencies for tracetest-onprem\e[0m\e[0m\n"
  helm dependency update "$PROJECT_ROOT/charts/tracetest-onprem"

  if [[ "$@" == *"--install-demo"* ]]; then
    printf "\n\e[42m\e[1mBuilding dependencies for pokeshop-demo\e[0m\e[0m\n"
    helm dependency update $PROJECT_ROOT/charts/pokeshop-demo
  fi
fi

SETUP_CLUSTER=false

if [[ "$@" == *"--reset"* ]]; then
  printf "\n\e[41m\e[1mDeleting existing cluster\e[0m\e[0m\n"
  kind delete cluster --name tracetest
fi

if ! kind get clusters | grep -q tracetest; then
  printf "\n\e[42m\e[1mCreating new cluster\e[0m\e[0m\n"
  SETUP_CLUSTER=true
  kind create cluster \
    --name tracetest \
    --config $PROJECT_ROOT/kind-config.yaml \
    --kubeconfig $KUBECONFIG_FILE
else 
  printf "\n\e[1mCluster already exists\e[0m\n"
fi

cat <<EOF > $ENV_FILE
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_FILE
kubectl config use-context kind-tracetest
EOF

source $ENV_FILE

if [[ "$SETUP_CLUSTER" == true ]]; then

    for chart_dir in $PROJECT_ROOT/charts/*; do
      printf "\n\e[42m\e[1mBuilding dependencies for $(basename "$chart_dir")\e[0m\e[0m\n"
      helm dependency update "$chart_dir"
    done


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

if [[ "$@" == *"--private"* ]]; then
  HELM_EXTRA_FLAGS+=(--set global.imagePullSecret=ghcr-secret)
  HELM_EXTRA_FLAGS+=(--set global.tracetestImageRegistry=ghcr.io/)
else 
  if [[ -z "$TRACETEST_LICENSE" ]]; then
    printf "\n\e[1;32mTracetest license not found on env. You can set it on \$TRACETEST_LICENSE to save time on installation.\e[0m\n"
    read -p $'\e[1;32m Enter your Tracetest license key:\e[0m ' TRACETEST_LICENSE
  else 
    printf "\n\e[1;32mReading Tracetest license username from env.\e[0m\n"
  fi

  HELM_EXTRA_FLAGS+=(--set global.licenseKey="$TRACETEST_LICENSE")
fi

printf "\n\e[42m\e[1mStarting Tracetest OnPrem components installation\e[0m\e[0m\n"

printf "\n\e[42m\e[1mInstalling Tracetest dependencies\e[0m\e[0m\n"
helm upgrade --install ttdeps $PROJECT_ROOT/charts/tracetest-dependencies -f $PROJECT_ROOT/values-kind.yaml "${HELM_EXTRA_FLAGS[@]}"

printf "\n\e[42m\e[1mInstalling Tracetest on-prem\e[0m\e[0m\n"
helm upgrade --install tt $PROJECT_ROOT/charts/tracetest-onprem -f $PROJECT_ROOT/values-kind.yaml "${HELM_EXTRA_FLAGS[@]}"

if [[ "$@" == *"--install-demo"* ]]; then
  printf "\n\e[42m\e[1mInstalling Pokeshop demo\e[0m\e[0m\n"
  helm upgrade --install ttdemo -n demo --create-namespace $PROJECT_ROOT/charts/pokeshop-demo -f $PROJECT_ROOT/values-kind-demo.yaml
fi

if [[ "$SETUP_CLUSTER" == true || "$@" == *"--config-coredns"* ]]; then
  printf "\n\e[42m\e[1mConfiguring CoreDNS\e[0m\e[0m\n"
  hosts=(tracetest.localdev)
  if [[ "$@" == *"--install-demo"* ]]; then
    hosts+=(pokeshop.localdev)
  fi

  $PROJECT_ROOT/scripts/coredns_config.sh ttdeps-traefik.default.svc.cluster.local "${hosts[@]}"
  printf "\n"
fi

# Capturing the end time
end_time=$(date +%s)

# Calculating elapsed time
elapsed=$((end_time - start_time))

printf "\e[42m\e[1mDone in $elapsed seconds!\e[0m\e[0m\n"