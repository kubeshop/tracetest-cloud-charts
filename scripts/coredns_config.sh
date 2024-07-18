#!/bin/bash

# Check that at least two arguments are passed
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <internalHostname> <hostname1> [<hostname2> ...]"
    exit 1
fi

# Assign the internal hostname to a variable
INTERNAL_HOSTNAME=$1

# Shift the arguments to process the hostnames
shift

# Initialize the CoreDNS configuration with the default settings
DEFAULT_COREDNS_CONFIG=$(cat <<EOF
.:53 {
    errors
    health {
        lameduck 5s
    }
    ready
EOF
)

# Iterate over each hostname to add rewrite rules
for HOSTNAME in "$@"; do
    DEFAULT_COREDNS_CONFIG+=$'\n'"    rewrite name $HOSTNAME $INTERNAL_HOSTNAME"
done

# Continue with the rest of the CoreDNS configuration
DEFAULT_COREDNS_CONFIG+=$(cat <<EOF

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

printf "\e[42m\e[1mCoreDNS configuration has been updated.\e[0m\e[0m\n"

# Print each rewrite rule added
for HOSTNAME in "$@"; do
    printf "\e[42m\e[1mThe hostname %s is now replaced with %s\e[0m\e[0m\n" "$HOSTNAME" "$INTERNAL_HOSTNAME"
done
