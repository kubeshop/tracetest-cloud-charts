# Tracetest On-Prem Helm Charts

Here you will find the Helm Charts for the [Tracetest](https://tracetest.io/) installation on-premises (i.e. in your infrastructure).

## Usage

[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

The main chart for this repository is called `tracetest-onprem` and contains all components necessary to run Tracetest on-premises on a cluster that fits the [prerequisites](./docs/prerequisites.md).

After you have a cluster that fits the prerequisites, you can install Tracetest On-prem by running the following command:

```sh
helm repo add tracetestcloud https://kubeshop.github.io/tracetest-cloud-charts

helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  --values values.yaml
```

Here are the detailed instructions to install Tracetest On-prem in your cluster:
 - [Development cluster](./docs/install-development-cluster.md)
 - [Production cluster](./docs/install-production-cluster.md)

## Configuration (values file specification)

| Parameter | Description | Default |
| --- | --- | --- |
TODO

### Examples

<details>
  <summary>Basic values.yaml with SSO, Database and Traefik defined</summary>

```yaml
global:
  urls:
    rootDomain: &rootDomain "tracetest.acme.com" #it's important to keep the `&rootDomain` part

  sso:
    google:
      clientID: "clientID"
      clientSecret: "clientSecret"
    github:
      clientID: "clientID"
      clientSecret: "clientSecret"

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

traefik:
  tls:
    issuerRef:
      name: issuer-selfsigned
      kind: ClusterIssuer
      group: cert-manager.io
```
</details>

## Questions

Feel free to reach us at [our Slack](https://dub.sh/tracetest-community) if you have any questions.

## License

[Tracetest Community License](./LICENSE)