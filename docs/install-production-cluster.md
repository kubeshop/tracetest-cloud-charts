# Installing in a Production Environment

## DNS

Tracetest needs to be accessible from outside the cluster, exposed via a [Traefik's](#Traefik) IngressRoute.
For this, it requires a DNS-resolvable name. You can use a public DNS, an intranet DNS, or even hostfile based,
as long as clients can resolve the hostnames to the correct IPs.

You can choose any hostname you want. This helm repo imposes no limitation on this.

If you choose to use a DNS resolving mechanism that is not available within the Kubernetes cluster where Tracetest runs, 
you can configure the cluster's CoreDNS to point the selected hostname to the Traefik Service. We provide a [script for this](./scripts/coredns_config.sh)

If you want to use managed agents and send OpenTelemetry trace data to them from outside the cluster, you need to set a wildcard subdomain.

> **Does this mean that Tracetest will be accessible from the internet?**
> 
> Not neccesarily. By default, most cloud providers will automatically map LoadBalancer services to public IPs.
> If you want to make your installation only availble within an intranet or similarly private environment,
> check how to configure Private IPs with your cloud provider docs.

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

In order to have a valid certificate, Cert Manager requires you to provide proof of ownership of the DNS domain that you are claiming.
You can see how to do that on the [Issuers documentation](https://cert-manager.io/docs/configuration/issuers/)

While it is not recommended in a production environment, you can get away by creating a SelfSigned Issuer and create self-signed certificates.
With Self Signed certificates you will see warnings on the browser when accessing your Tracetest OnPrem instance Web UI.

```sh
# Create a self signed certificate

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

Tracetest relies on Traefik for its exposed web UI and API, as well as for the managed agents.
The process is simple, but the process for exposing the Traefik deployment might differ depending on the cloud platform.
See [Install Traefik using Helm Chart](https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart)

## External Services

Tracetest requires two databases to operate

### PostgreSQL

We recommend using an out-of-cluster instance. Version should not matter a lot, but it is always a good idea to have the latest.

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

We recommend using an out-of-cluster instance. Version should not matter a lot, but it is always a good idea to have the latest.

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
  sso:
    google:
      clientID: "clientID"
      clientSecret: "clientSecret"
    github:
      clientID: "clientID"
      clientSecret: "clientSecret"
```  