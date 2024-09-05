#!/usr/bin/env bash

set -e

export KUBECONFIG=$KUBECONFIG:$(pwd)/tracetest.kubeconfig
kubectl config use-context kind-tracetest

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")

printf "\n\e[42m\e[1mInstalling Pokeshop demo\e[0m\e[0m\n"
helm upgrade --install ttdemo -n demo --create-namespace $PROJECT_ROOT/charts/pokeshop-demo -f $PROJECT_ROOT/values-kind-demo.yaml

printf "\n\e[42m\e[1mConfiguring CoreDNS\e[0m\e[0m\n"
hosts=(tracetest.localdev)
hosts+=(pokeshop.localdev)

$PROJECT_ROOT/scripts/coredns_config.sh ttdeps-traefik.default.svc.cluster.local "${hosts[@]}"
printf "\n"