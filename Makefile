.PHONY: help
help: Makefile ## show list of commands
	@echo "Choose a command run:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: onprem/template
onprem/template: ## generate k8s manifests of onprem and output to stdout
	@helm template tracetest-onprem ./charts/tracetest-onprem

.PHONY: onprem/build-deps
onprem/build-deps: ## build helm dependencies for onprem charts
	@sh ./scripts/update_chart_deps.sh

.PHONY: onprem/delete-cluster
onprem/delete-cluster: ## delete current onprem cluster
	@kind delete cluster --name tracetest

.PHONY: onprem/private-cluster
onprem/private-cluster: ## create onprem private cluster
	@sh ./scripts/setup_kind_cluster.sh --reset --private --build-deps

.PHONY: onprem/cluster
onprem/cluster: ## create onprem cluster
	@sh ./scripts/setup_kind_cluster.sh --reset --build-deps

.PHONY: onprem/k9s
onprem/k9s: ## run k9s on onprem cluster locally installed
	@sh ./scripts/start_k9s.sh