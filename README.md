# tracetest-cloud-charts

This is the helm repo for the on prem instalation of Tracetest

## DNS

Tracetest needs to be accesible from outside the cluster, exposed via a [Traefik's](#Traefik) IgressRoute.
For this, it requires a DNS resolvable name. You can use a public DNS, an intranet DNS, or even hostfile based,
as long as clients are able to resolve the hostnames to the correct IPs.

You can choose any hostname you want. Tracetest imposes no limitation on this.

If you choose to use a resolving mechanism that is not available within the Kuberetes cluster where Tracetest runs, 
you can configure the clusters CoreDNS to point the selected hostname to the Traefik Service. We provide a [script for this](./scripts/coredns_config.sh)

If you want to use managed agents, and send tracing info to them from outside the cluster, you need to set a wildcard subdomain.

**Example**

Your main domain is `tracetest.acme.com`. You need to setup `tracetest.acme.com` and `*.tracetest.acme.com` to the LoadBalancer IP.


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

Tracetest relies on Traefik for its exposed web UI and API, as well for the managed agents.
The process is simple, but the process for exposing the Traefik deplyment might differ depending on the cloud platform.
See [Install Traefik using Helm Chart](https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart)

## External Services

Tracetest requires two databases to operate

### PostgreSQL

We recommend using an out of cluster instance. Version should not matter a lot, but it is always a good idea to have the latest.

You can configure the credentials in `values.yaml`:

```yaml
global:
  postgresql:
    auth:
      host: "ttdeps-postgresql"
      username: "postgres"
      password: "postgres"
      database: "tracetest"
```

### MongoDB

We recommend using an out of cluster instance. Version should not matter a lot, but it is always a good idea to have the latest.

You can configure the credentials in `values.yaml`:

```yaml
global:
  mongodb:
    auth:
      protocol: "mongodb"
      host: "ttdeps-tracetest-dependencies-mongodb"
      username: "mongodb"
      password: "mongodb"
      database: "tracetest"
      options:
        retryWrites: "true"
        authSource: admin
```

# SSO

This chart comes with a **EXTREMELY INSECURE** default GitHub OAuth App. It is used for demo purposes only, and should not under any circumstances be used in  any real environment.

**TODO: add guides on how to setup oauth apps**

You can enable GitHub and Google SSO by creating corresponding Apps and setting the credentials in `values.yaml`:

```yaml
global:
    google:
      clientID: "clientID"
      clientSecret: "clientSecret"
    github:
      clientID: "clientID"
      clientSecret: "clientSecret"
```

## Installing the chart.

`tracetest-onprem` is an umbrella chart that simplifies the installation of Tracetest on a cluster that fits the prerequisites.

The basic steps to install are:
```sh
helm repo add tracetestcloud https://kubeshop.github.io/tracetest-cloud-charts

helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  -f values.yaml
```

Here's an example values.yaml:

```yaml
global:
  urls:
    rootDomain: &rootDomain "tracetest.acme.com" #it's important to keep the `&rootDomain` part

  postgresql:
    auth:
      host: "ttdeps-postgresql"
      username: "postgres"
      password: "postgres"
      database: "tracetest"

  mongodb:
    auth:
      protocol: "mongodb"
      host: "ttdeps-tracetest-dependencies-mongodb"
      username: "mongodb"
      password: "mongodb"
      database: "tracetest"
      options:
        retryWrites: "true"
        authSource: admin
```

# Developing

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