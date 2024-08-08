#!/bin/bash

set -e

get_path() {
    path=$1
    PWD=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
    realPath="$PWD/$path"

    echo $realPath
}

source `get_path ./update_chart_references.sh`
source `get_path ./git.sh`

# Update the `appVersion` in each chart affected by a new release
# Parameters:
# @string projectName
# @string version
projectName=$1
version=$2

update_chart_references $projectName $version `get_path ./update_chart_instructions.yaml`

git add `get_path ../charts`
git status

commit_and_push "Bump chart to version $version"