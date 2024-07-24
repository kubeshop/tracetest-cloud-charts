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

Now you can access the app at https://tracetest.localdev:30000
The pokeshop demo is available at https://pokeshop.localdev:30000