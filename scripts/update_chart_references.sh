#!/bin/bash

update_chart_references() {
    REPO_NAME=$1
    NEW_TAG=$2
    INSTRUCTIONS_FILE=$3

    instructions=`yq e ".${REPO_NAME}" -o=json "$INSTRUCTIONS_FILE"`
    if [[ "$instructions" != "null" ]]; then
        echo "$instructions" | jq -c .[] | while read -r line; do
            FILE=$(echo $line | jq -r '.file')
            JSON_PATH=$(echo $line | jq -r '.jsonpath')
            SED_EXPRESSION=$(echo $line | jq -r '.sed_expression // empty')
            ABSOLUTE_FILE_PATH=`get_path ../$FILE`

            echo "$FILE:"
            echo "  JSON path: $JSON_PATH"

            if [[ -n "$SED_EXPRESSION" ]]; then
                echo "  SED expression: " '"'$SED_EXPRESSION'"'
                # Use yq to get the value, and then sed to update it
                ORIGINAL_VALUE=$(yq e "$JSON_PATH" "$ABSOLUTE_FILE_PATH")
                REPLACED_SED_EXPRESSION=$(echo "$SED_EXPRESSION" | sed "s/{{TAG}}/$NEW_TAG/g")
                UPDATED_VALUE=$(echo "$ORIGINAL_VALUE" | sed "$REPLACED_SED_EXPRESSION")
                yq e "$JSON_PATH = \"$UPDATED_VALUE\"" -i "$ABSOLUTE_FILE_PATH"
            else
                # Default handling for direct JSON paths
                yq e "$JSON_PATH = \"$NEW_TAG\"" -i "$ABSOLUTE_FILE_PATH"
            fi
            echo
        done
    fi
}