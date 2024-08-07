# Installing in a Development Environment

> [!NOTE]
> This instalation is meant for testing purposes only. It uses self signed certificates, so your browser will show a warning about it.

To install Tracetest OnPrem in a development environment, and get a first glimpse of how it works, you can follow the instructions below.

We provide a development install via a script that you can use to run Tracetest OnPrem locally on your machine. The only prerequisite is that you have [kind](https://kind.sigs.k8s.io/) installed.

You can then run the following command and follow the instructions when needed:
```sh
curl -sSL https://raw.githubusercontent.com/kubeshop/tracetest-cloud-charts/main/scripts/setup_kind_cluster.sh | bash -- --install-install-demo
```

You need to add the following lines to your `/etc/hosts` file to access Tracetest:
```sh
sudo sh -c 'echo "127.0.0.1 tracetest.localdev" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 pokeshop.localdev" >> /etc/hosts'
```

This setup will configure a local kind cluster with Tracetest OnPrem and a demo [PokeShop API](https://docs.tracetest.io/live-examples/pokeshop/overview), with all networking and prerequisites configured to work locally. For more details, see [Prerequisites](./prerequisites.md). 

After setting up your `hosts` file, you can go to the following links:
- https://tracetest.localdev:30000 and check Tracetest Web UI, creating a user and an organization for you
- https://pokeshop.localdev:30000 and run tests against the demo [PokeShop API](https://docs.tracetest.io/live-examples/pokeshop/overview)