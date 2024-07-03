# tracetest-cloud-charts

TODO: make this nice

this repo provides a script to create a local kind cluster with an entire Tracetest cloud instance. 
while we have this repo private and all the private images, this is just deploying Tracetest cloud.
we need to use a secret so you need to use the create image pull secret script to configure that in the kind cluster.

once everything is public, we can use kind to validate PRs before merging.
this can also become the main helm repo for cloud, since it has a much nicer approach, but we'll see if that works out without needing too much customization

## TLDR

[kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) and [helm](https://helm.sh/docs/intro/install/) are required to run and test this repo

```
helm repo add traefik https://traefik.github.io/charts
helm repo add ory https://k8s.ory.sh/helm/charts
helm repo add jetstack https://charts.jetstack.io
helm repo add nats https://nats-io.github.io/k8s/helm/charts/

export CURRENT_FOLDER=$PWD
export TT_CHARTS=("tracetest-agent-operator" "tracetest-auth" "tracetest-cloud" "tracetest-core" "tracetest-frontend" "tracetest-onprem" "tracetest-dependencies")

for chart_name in $TT_CHARTS; do 
    cd $CURRENT_FOLDER/charts/$chart_name
    helm dependency build
done
 
cd $CURRENT_FOLDER

./scripts/setup_kind_cluster.sh --reset --private
sudo sh -c 'echo "127.0.0.1 tracetest.localdev" >> /etc/hosts'
source ./cluster.env
kubectl get pods
```

now you can access the app at https://tracetest.localdev

## charts

the tracetest-onprem chart is the main umbrella chart. 

tracetest-dependencies is mainly for development/PR validation. it installs cert manager and other dependencies that can be considered "external", like traefik, postgres, etc.
onprem users will have to configure this externally, so we'll need docs for that (like testkube has for the nginx ingerss controller)

one exception is cert-manager, that is a dependency but is very very hard to install as a subchart, so it's installed in the kind setup script

tracetest-auth is an umbrella for grouping all the ory services toghether

tracetest-core and tracetest-cloud are copypasted from the infra repo so they are a base, but we can modify them as we want without impacting our cloud infra.