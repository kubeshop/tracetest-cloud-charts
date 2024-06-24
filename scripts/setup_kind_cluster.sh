#!/bin/bash

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
KUBECONFIG_FILE=$(pwd)/tracetest.kubeconfig
ENV_FILE=$PROJECT_ROOT/cluster.env


if [[ "$1" == "--reset" ]]; then
  kind delete cluster --name tracetest
fi

if ! kind get clusters | grep -q tracetest; then
  kind create cluster  --name tracetest --kubeconfig $KUBECONFIG_FILE
else 
  echo "Cluster already exists"
fi

cat <<EOF > $ENV_FILE
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_FILE
kubectl config use-context kind-tracetest
EOF

source $ENV_FILE

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