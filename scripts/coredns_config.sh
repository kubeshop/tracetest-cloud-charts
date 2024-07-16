#!/bin/bash

# Check that exactly two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <hostname> <namespace/serviceName>"
    exit 1
fi

# Assign arguments to variables
HOSTNAME=$1
INTERNAL_HOSTNAME=$2

# Default CoreDNS configuration with the custom entry
DEFAULT_COREDNS_CONFIG=$(cat <<EOF
.:53 {
    errors
    health {
        lameduck 5s
    }
    ready
    rewrite name $HOSTNAME $INTERNAL_HOSTNAME
    kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
        ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
        max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
}
EOF
)

# Update the CoreDNS ConfigMap with the new configuration
kubectl create configmap -n kube-system coredns --from-literal=Corefile="$DEFAULT_COREDNS_CONFIG" -o yaml --dry-run=client | kubectl apply -f -
kubectl rollout restart -n kube-system deployment/coredns

printf "\e[42m\e[1mCoreDNS configuration has been updated. The hostname %s is now replaced to %s\e[0m\e[0m\n" "$HOSTNAME" "$INTERNAL_HOSTNAME"
