#!/bin/bash

set -e



get_path() {
    path=$1
    PWD=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
    realPath="$PWD/$path"

    echo $realPath
}

source `get_path ./update_chart_references.sh`

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
update_chart_references $projectName $version `get_path ./update_chart_instructions.yaml`

for chart in "${affectedCharts[@]}"
do
    path="$chart/Chart.yaml"
    oldVersion=`yq '.appVersion' $path`
    sed -i "s/appVersion: $oldVersion/appVersion: $version/g" $path
done

git add `get_path ../charts`
git commit -m "Bump chart to version $version"
git push --force-with-lease