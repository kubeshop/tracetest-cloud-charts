# tracetest-cloud-charts

## DNS

Tracetest needs to be accesible from outside the cluster, exposed via a [Traefik's](#Traefik) IgressRoute.
For this, it requires a DNS resolvable name. You can use a public DNS, an intranet DNS, or even hostfile based,
as long as clients are able to resolve the hostnames to the correct IPs.

You can choose any hostname you want. Tracetest imposes no limitation on this.

If you choose to use a resolving mechanism that is not available within the Kuberetes cluster where Tracetest runs, 
you can configure the clusters CoreDNS to point the selected hostname to the Traefik Service. We provide a [script for this](./scripts/coredns_config.sh)


## Cluster prerequisites

Tracetest expects some preconditions in the environment where it runs.

### Cert manager

Tracetest uses cert-manager to create sign certificates for JWT tokens, and SSL certificates for Ingress.

Quick install:
```
helm repo add jetstack https://charts.jetstack.io --force-update
  helm upgrade --install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.15.0 \
    --set crds.enabled=true
```

Cert Manager defines Issuers. If you have existing Issuers that you want to use, you can configure them in `values.yaml`.

You can also create a SelfSigned issuer and create self signed certificates:
```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: issuer-selfsigned
  labels:
spec:
  selfSigned: {}
EOF
```

### Traefik

Tracetest relies on Traefik for its exposed web UI and API, as well for the managed 

## External Services

### PostgreSQL

### MongoDB

this repo provides a script to create a local kind cluster with an entire Tracetest cloud instance. 
while we have this repo private and all the private images, this is just deploying Tracetest cloud.
we need to use a secret so you need to use the create image pull secret script to configure that in the kind cluster.

once everything is public, we can use kind to validate PRs before merging.
this can also become the main helm repo for cloud, since it has a much nicer approach, but we'll see if that works out without needing too much customization

## TLDR

[kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) and [helm](https://helm.sh/docs/intro/install/) are required to run and test this repo

```
./scripts/setup_kind_cluster.sh --install-demo --reset --build-deps
sudo sh -c 'echo "127.0.0.1 tracetest.localdev" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 pokeshop.localdev" >> /etc/hosts'
source ./cluster.env
kubectl get pods
```

now you can access the app at https://tracetest.localdev:30000
The pokeshop demo is available at https://pokeshop.localdev:30000

## charts

the tracetest-onprem chart is the main umbrella chart. 

tracetest-dependencies is mainly for development/PR validation. it installs cert manager and other dependencies that can be considered "external", like traefik, postgres, etc.
onprem users will have to configure this externally, so we'll need docs for that (like testkube has for the nginx ingerss controller)

one exception is cert-manager, that is a dependency but is very very hard to install as a subchart, so it's installed in the kind setup script

tracetest-auth is an umbrella for grouping all the ory services together

tracetest-core and tracetest-cloud are copypasted from the infra repo so they are a base, but we can modify them as we want without impacting our cloud infra.