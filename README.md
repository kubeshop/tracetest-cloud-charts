# Tracetest On-Prem Helm Charts

This repository contains the Helm Charts for the [Tracetest](https://tracetest.io/) installation on-premises (i.e. in your infrastructure).

## Usage

[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

The main chart for this repository is called `tracetest-onprem` and contains all components necessary to run Tracetest on-premises on a cluster that fits the [prerequisites](./docs/prerequisites.md).

You will need to have a license key to install Tracetest On-prem. If you don't have one, you can request a trial license key [here](https://tracetest.io/on-prem-installation).

After you have a cluster that fits the prerequisites, you can install Tracetest On-prem by running the following command:

```sh
helm repo add tracetestcloud https://kubeshop.github.io/tracetest-cloud-charts --force-update

helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  --values values.yaml
```

Here are the detailed instructions to install Tracetest On-prem in your cluster:
 - [Development cluster](./docs/install-development-cluster.md)
 - [Production cluster](./docs/install-production-cluster.md)

## Configuration (values file specification)

You can see the main configurable parameters of the Tracetest On-prem chart and their default values here: [values.yaml](https://github.com/kubeshop/tracetest-cloud-charts/blob/main/charts/tracetest-onprem/values.yaml).

<details>
  <summary>Default values.yaml</summary>

```yaml
global:
  # License Key provided by Tracetest team to run this instance. Default: `""`
  licenseKey: ""
  
  # This value defines if clients should expect a valid SSL certificate from the server. If you are using a self-signed certificate, you should set this to false. Default: `true`
  validCertificate: true
  
  # Pull secrets name used to fetch images from a private registry if needed. If set empty, this chart will use the public registry. For more details see: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ Default: `""`
  imagePullSecret: ""
  # Registry name used to fetch images. If set empty, this chart will use the public registry. For more details see: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ Default: `""`
  tracetestImageRegistry: ""

  sso:
    google:
      # Google OAuth2 client ID. You can get these from the Google Developer Console. Default: `""`
      clientID: "" 
      # Google OAuth2 secret. You can get these from the Google Developer Console. Default: `""`
      clientSecret: ""
    github:
      # Github OAuth2 client ID. You can get these from the Github Developer Console. Default: `"example client ID"`
      clientID: "Ov23li8WMwQlvjFNNiCy"
      # Github OAuth2 secret. You can get these from the Github Developer Console. Default: `"example client secret"`
      clientSecret: "e317c15e43909757d1e75e78373d130c374f6601"

  # If you don't want to use the default NATS server, you can specify your own NATS server here
  # natsEndpointOverride: "://nats:4222"

  postgresql:
    auth:
      # Postgres host address. Default: `""`
      host: ""
      # Postgres username that Tracetest APIs will use. Default: `""`
      username: ""
      # Postgres password that Tracetest APIs will use. Default: `""`
      password: ""
      # Postgres database name for Tracetest OnPrem. Default: `"tracetest"`
      database: "tracetest"
      # Postgres port. Default: `"5432"`
      port: "5432"
    
  mongodb:
    auth:
      # MongoDB connection protocol. Default: `"mongodb"`
      protocol: "mongodb"
      # MongoDB host address. Default: `""`
      host: ""
      # MongoDB username that Tracetest APIs will use. Default: `""`
      username: ""
      # MongoDB password that Tracetest APIs will use. Default: `""`
      password: ""
      # MongoDB database name for Tracetest OnPrem. Default: `"tracetest"`
      database: ""
      # MongoDB connection options as a key-value object. Default: `"{}"`
      options: {}

  
  # URLs section with addresses used by clients to connect to the Tracetest OnPrem instance
  urls:
    protocol: &protocol "https"
    port: &port "30000"
    rootDomain: &rootDomain "tracetest.localdev"
    cookieDomain: *rootDomain
    
    web:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
      path: "/"
    
    api:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
      path: "/api"

    auth:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
      path: "/auth"
    
    agents:
      domain: *rootDomain
      port: *port
    
    controlPlane:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
      path: "/"

nats:
  enabled: true
  
  config:
    jetstream:
      enabled: true
      fileStore:
        enabled: true
        dir: /data
        pvc:
          enabled: true
          size: 10Gi
      memoryStore:
          enabled: true
          maxSize: 1Gi

    natsBox:
      container:
        env:
          # different from k8s units, suffix must be B, KiB, MiB, GiB, or TiB
          # should be ~90% of memory limit
          GOMEMLIMIT: 900MiB
        merge:
          # recommended limit is at least 2 CPU cores and 8Gi Memory for production JetStream clusters
          resources:
            requests:
              cpu: 250m # one entire CPU
              memory: 1Gi
            limits:
              memory: 1Gi


```

</details>

### Examples

<details>
  <summary>Basic values.yaml with SSO and Database defined</summary>

```yaml
global:
  validCertificate: false # defines if the certificate is generated by an external issuer of if the self-signed issuer is used

  urls:
    protocol: &protocol "https"
    port: &port "30000" 
    rootDomain: &rootDomain "tracetest.mydomain.com" # DNS that the users will use to access the Tracetest
    cookieDomain: *rootDomain
    
    web:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
    
    api:
      protocol: *protocol
      hostname: *rootDomain
      port: *port

    auth:
      protocol: *protocol
      hostname: *rootDomain
      port: *port
    
    agents:
      domain: *rootDomain
      port: *port
    
    controlPlane:
      protocol: *protocol
      hostname: *rootDomain
      port: *port

  postgresql:
    auth:
      host: "path.to.my.postgres.instance"
      username: "some-pg-user"
      password: "some-pg-password"
      database: "tracetest"

  mongodb:
    auth:
      protocol: "mongodb"
      host: "path.to.my.mongodb.instance"
      username: "some-mongo-user"
      password: "some-mongo-password"
      database: "tracetest"
      options:
        retryWrites: "true"
        authSource: admin
```
</details>

## Cluster sizing

Depending on the size of your organization, your deployment might require different sizes. We provide a `small` and `large` deployment sizing examples.
To use it you can:

```
# large cluster
helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  --values <your-values.yaml> \
  --values https://raw.githubusercontent.com/kubeshop/tracetest-cloud-charts/main/values-cluster-large.yaml
```

```
# small cluster
helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  --values <your-values.yaml> \
  --values https://raw.githubusercontent.com/kubeshop/tracetest-cloud-charts/main/values-cluster-small.yaml
```

## Questions

Feel free to contact us at [our Slack](https://dub.sh/tracetest-community) if you have any questions.

## License

[Tracetest Community License](./LICENSE)