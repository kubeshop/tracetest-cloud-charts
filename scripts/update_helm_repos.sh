echo "Update helm repositories"
echo ""

helm repo add traefik https://traefik.github.io/charts --force-update
helm repo add ory https://k8s.ory.sh/helm/charts --force-update
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add nats https://nats-io.github.io/k8s/helm/charts/ --force-update
helm repo add opentelemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update