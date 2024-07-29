# Basic concepts

Tracetest is composed of a few different internal services. To simplify access to the different parts when using the CLI and Web UI, 
it relies on the [Traefik Proxy](https://traefik.io/traefik/).

All incoming connections are secured using HTTPS/TLS. Tracetest relies on [cert-manager](https://cert-manager.io) to create and maintain certificates.
Cert Manager is a complete solution for managing certificates in an automated way. By default, Tracetest comes preconfigured with a self-signed certificate.
While this is secure enough for testing, it will create warnings to users accessing the Web UI in most browsers.

We recommend configuring a production-ready [Issuer](https://cert-manager.io/docs/configuration/issuers/) for CertManager to provide the best user experience and security.

## Exposure to the Internet

Tracetest doesn't require to be exposed to the public internet. However, clients will need to be able to communicate with the Tracetest services.
By clients we mean CLI on developer machines, CI/CD actions, and even the Web UI on the user's machine.

The simplest solution is to rely on [Kubernetes LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/) to expose the Traefik Proxy that Tracetest uses.

Does this means that your Tracetest instance needs to be accessible from the public internet? No! Depending on your cloud infrastructure, you can have clusters that are only accessible from the VPC,
allowing permitted clients to access via VPN, for example. There are endless ways to configure Kubernetes, and it is outside the scope of this documentation.
We are happy to help you deciding what's the best way to expose your On-prem deployment, so feel free to reach us at [our Slack](https://dub.sh/tracetest-community).

## Executing a Test Run

You likely want to do a quick test run without dealing with all the complexities of a production-level Kuberentes deployment.
We provide a script that you can use to run Tracetest OnPrem locally on your machine. The only prerequisite is that you have [kind](https://kind.sigs.k8s.io/) and [helm](https://helm.sh/docs/intro/install/) installed.

You can then run the following command:
```sh
curl -sSL https://raw.githubusercontent.com/kubeshop/tracetest-cloud-charts/main/scripts/setup_kind_cluster.sh | bash -- --install-install-demo
```

You need to add the following lines to your `/etc/hosts` file to access Tracetest:
```sh
sudo sh -c 'echo "127.0.0.1 tracetest.localdev" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 pokeshop.localdev" >> /etc/hosts'
```

You can now go to [https://tracetest.localdev:30000] to check tracetest, and run tests against the demo PokeShop App at [https://pokeshop.localdev:30000]

> NOTE
> This instalation is meant for testing purposes only. It uses self signed certificates, so your browser will show a warning about it.
> The Traefik Proxy is exposed via NodePort, which is not recommended for production environments.
> Finally, the required databases are installed within the cluster, and that might not be desireable.

# Installing on a Production Environment

<details>
  <summary>Click here to see more details </summary>

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
</details>