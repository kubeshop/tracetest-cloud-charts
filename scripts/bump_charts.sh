#!/bin/bash

ONPREM_CHART_FILE="charts/tracetest-onprem/Chart.yaml"
ONPREM_CHART_NAME="tracetest-onprem"

changed_charts=$(git --no-pager diff --name-only HEAD~1 charts | grep '/' | cut -d'/' -f1-2 | uniq)

# If no changed charts, exit with a message
if [[ -z "$changed_charts" ]]; then
  echo "No charts have been changed."
  exit 0
fi

# Loop through the unique charts and run pybump on each Chart.yaml
for chart in $changed_charts; do
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

  echo "Update $chartName to $newChartVersion in $ONPREM_CHART_FILE"
  yq eval '.dependencies[] |= (select(.name == "'"$chartName"'").version = "'"$newChartVersion"'")' "$ONPREM_CHART_FILE" -i

  if [[ $? -ne 0 ]]; then
    echo "Error occurred while updating $chartName in $ONPREM_CHART_FILE"
    exit 1
  fi

  git add "$chart/Chart.*"
done

echo "Bumping version of $ONPREM_CHART_FILE"
newVersion=$(pybump bump --file "$ONPREM_CHART_FILE" --level minor)
if [[ $? -ne 0 ]]; then
  echo "Error occurred while bumping the minor version of $ONPREM_CHART_FILE"
  exit 1
fi
echo "Updated version: $newVersion"

git add $ONPREM_CHART_FILE

git status
git commit -m "Update tracetest-onprem version to $newVersion"
git push --force-with-lease