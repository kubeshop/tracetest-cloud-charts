#!/bin/bash

printf "\n\e[42m\e[1mPersiste kubeconfig file\e[0m\e[0m\n"
kind get kubeconfig --name tracetest > ~/.kube/config

printf "\n\e[42m\e[1mConfigure host DNS\e[0m\e[0m\n"
# setup custom DNS resolve
sudo echo "127.0.0.1 tracetest.localdev" | sudo tee -a /etc/hosts
sudo echo "127.0.0.1 pokeshop.localdev" | sudo tee -a /etc/hosts

kubectl wait --for=condition=available --timeout=60s deployment/cloudagent-tracetest-agent
printf "\n\e[42m\e[1mCloudAgent deployed\e[0m\e[0m\n"