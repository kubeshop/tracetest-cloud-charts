# Tracetest On-Prem Helm Charts

Here you will find the Helm Charts for the [Tracetest](https://tracetest.io/) installation on-premises (i.e. in your infrastructure).

## Usage

[Helm](https://helm.sh/) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

The main chart for this repository is called `tracetest-onprem` and contains all components necessary to run Tracetest on-premises on a cluster that fits the prerequisites.

Here are the prerequisites to install Tracetest On-prem in your cluster:
 - [Development cluster](./docs/install-on-development-cluster.md)
 - [Production cluster](./docs/install-on-production-cluster.md)

After you have a cluster that fits the prerequisites, you can install Tracetest On-prem by running the following command:

```sh
helm repo add tracetestcloud https://kubeshop.github.io/tracetest-cloud-charts

helm install my-tracetest tracetestcloud/tracetest-onprem \
  --set global.licenseKey=YOUR-TRACETEST-LICENSE \
  --values values.yaml
```

## Configuration (values file specification)

TODO

## License

[Tracetest Community License](./LICENSE)