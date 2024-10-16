echo "Add helm repositories"
echo ""

helm repo add traefik https://traefik.github.io/charts --force-update
helm repo add ory https://k8s.ory.sh/helm/charts --force-update
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add nats https://nats-io.github.io/k8s/helm/charts/ --force-update
helm repo add opentelemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update

PROJECT_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")

for chart_dir in $PROJECT_ROOT/charts/*; do
    printf "\n\e[42m\e[1mClear dependencies for $(basename "$chart_dir")\e[0m\e[0m\n"
    rm  "$chart_dir/charts/*"

    printf "\n\e[42m\e[1mBuilding dependencies for $(basename "$chart_dir")\e[0m\e[0m\n"
    helm dependency update "$chart_dir"
done