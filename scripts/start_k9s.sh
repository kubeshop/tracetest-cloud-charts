#!/usr/bin/env bash

set -e

export KUBECONFIG=$KUBECONFIG:$(pwd)/tracetest.kubeconfig
kubectl config use-context kind-tracetest

k9s