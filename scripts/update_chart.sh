#!/bin/bash

set -e

# Update the `appVersion` in each chart affected by a new release
# Parameters:
# @string projectName
# @string version
projectName=$1
version=$2

affectedCharts=()

populate_affected_charts() {
    projectName=$1

    if [[ "$projectName" == "core" ]]; then
        affectedCharts+=("charts/tracetest-core")
    elif [[ "$projectName" == "cloud" ]]; then
        affectedCharts+=("charts/tracetest-cloud")
        affectedCharts+=("charts/tracetest-agent-operator")
        affectedCharts+=("charts/tracetest-monitor-operator")
    elif [[ "$projectName" == "frontend" ]]; then
        affectedCharts+=("charts/tracetest-frontend")
    elif [[ "$projectName" == "pokeshop" ]]; then
        affectedCharts+=("charts/pokeshop-demo")
    fi
}

populate_affected_charts $projectName

for chart in "${affectedCharts[@]}"
do
    path="$chart/Chart.yaml"
    oldVersion=`yq '.appVersion' $path`
    sed -i "s/appVersion: $oldVersion/appVersion: $version/g" $path
done