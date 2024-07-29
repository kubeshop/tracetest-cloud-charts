# Pre-requisites to install Tracetest OnPrem

Tracetest is composed of a few different internal services to properly work.

To simplify access to the different parts when using the CLI and Web UI, it relies on the [Traefik Proxy](https://traefik.io/traefik/).

All incoming connections are secured using HTTPS/TLS. Tracetest relies on [cert-manager](https://cert-manager.io) to create and maintain certificates.
Cert Manager is a complete solution for managing certificates in an automated way. By default, Tracetest comes preconfigured with a self-signed certificate.
While this is secure enough for testing, it will create warnings to users accessing the Web UI in most browsers.

We recommend configuring a production-ready [Issuer](https://cert-manager.io/docs/configuration/issuers/) for CertManager to provide the best user experience and security.

## Exposure to CLI and Web clients

Tracetest doesn't require to be exposed to the public internet. However, clients will need to be able to communicate with the Tracetest services.
By clients we mean CLI on developer machines, CI/CD actions, and even the Web UI on the user's machine.

The simplest solution is to rely on [Kubernetes LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/) to expose the Traefik Proxy that Tracetest uses.

This does not mean that your Tracetest instance needs to be accessible from the public internet. Depending on your cloud infrastructure, you can have clusters that are only accessible from the VPC,
allowing permitted clients to access via VPN, for example. There are endless ways to configure Kubernetes, and it is outside the scope of this documentation.