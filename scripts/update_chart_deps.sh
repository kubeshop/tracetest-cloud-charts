echo "Add helm repositories"
echo ""

helm repo add traefik https://traefik.github.io/charts
helm repo add ory https://k8s.ory.sh/helm/charts
helm repo add jetstack https://charts.jetstack.io
helm repo add nats https://nats-io.github.io/k8s/helm/charts/