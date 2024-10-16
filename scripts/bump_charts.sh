#!/bin/bash

ONPREM_CHART_FILE="charts/tracetest-onprem/Chart.yaml"
ONPREM_REQUIREMENTS_FILE="charts/tracetest-onprem/requirements.yaml"
ONPREM_CHART_NAME="tracetest-onprem"

# due to a problem on our helm build process, if we don't bump the version of charts
# that have dependencies, the build process doesn't not add the dependencies to tracetest-onprem
changed_charts=(tracetest-auth tracetest-core tracetest-monitor-operator tracetest-agent tracetest-cloud tracetest-common tracetest-agent-operator tracetest-frontend tracetest-public-endpoint)
# changed_charts=$(git --no-pager diff --name-only HEAD~1 charts | grep '/' | cut -d'/' -f1-2 | uniq)

# If no changed charts, exit with a message
if [[ -z "$changed_charts" ]]; then
  echo "No charts have been changed."
  exit 0
fi

# Assuming TRACETEST_COMMON_NAME is the name of the tracetest-common chart
TRACETEST_COMMON_NAME="tracetest-common"
TRACETEST_COMMON_NEW_VERSION=""

# Loop through the unique charts and run pybump on each Chart.yaml
for chart in "${changed_charts[@]}"; do
  chartName=$(basename "$chart")
  if [[ "$chartName" == "$ONPREM_CHART_NAME" ]]; then
    continue
  fi

  echo "Running pybump on $chart/Chart.yaml"
  newChartVersion=$(pybump bump --file "$chart/Chart.yaml" --level minor)

  if [[ $? -ne 0 ]]; then
    echo "Error occurred while running pybump on $chart/Chart.yaml"
    exit 1
  fi

  # Store the new version of tracetest-common
  if [[ "$chartName" == "$TRACETEST_COMMON_NAME" ]]; then
    TRACETEST_COMMON_NEW_VERSION=$newChartVersion
  fi

  echo "Update $chartName to $newChartVersion in $ONPREM_CHART_FILE"
  yq eval '.dependencies[] |= (select(.name == "'"$chartName"'").version = "'"$newChartVersion"'")' "$ONPREM_CHART_FILE" -i
  yq eval '.dependencies[] |= (select(.name == "'"$chartName"'").version = "'"$newChartVersion"'")' "$ONPREM_REQUIREMENTS_FILE" -i

  if [[ $? -ne 0 ]]; then
    echo "Error occurred while updating $chartName in $ONPREM_CHART_FILE"
    exit 1
  fi

  git add "$chart/Chart.*"
done

# If tracetest-common was updated, loop through all charts to update its version
if [[ -n "$TRACETEST_COMMON_NEW_VERSION" ]]; then
  for chart in $all_charts; do
    chartName=$(basename "$chart")
    # Skip updating tracetest-common itself
    if [[ "$chartName" == "$TRACETEST_COMMON_NAME" ]]; then
      continue
    fi

    # Check if the chart has tracetest-common as a dependency and update its version
    if yq eval '.dependencies[] | select(.name == "'"$TRACETEST_COMMON_NAME"'")' "$chart/Chart.yaml" -e; then
      echo "Updating $TRACETEST_COMMON_NAME version in $chartName to $TRACETEST_COMMON_NEW_VERSION"
      yq eval '.dependencies[] |= (select(.name == "'"$TRACETEST_COMMON_NAME"'").version = "'"$TRACETEST_COMMON_NEW_VERSION"'")' "$chart/Chart.yaml" -i
      git add "$chart/Chart.yaml"
    fi
  done
fi

echo "Bumping version of $ONPREM_CHART_FILE"
newVersion=$(pybump bump --file "$ONPREM_CHART_FILE" --level minor)
if [[ $? -ne 0 ]]; then
  echo "Error occurred while bumping the minor version of $ONPREM_CHART_FILE"
  exit 1
fi
echo "Updated version: $newVersion"

git add $ONPREM_CHART_FILE $ONPREM_REQUIREMENTS_FILE

git status
git commit -m "Update tracetest-onprem version to $newVersion"
git push --force-with-lease