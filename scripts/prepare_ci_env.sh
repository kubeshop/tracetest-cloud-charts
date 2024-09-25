#!/bin/bash

if [[ "$*" == *"--debug"* ]]; then
  set -x
fi

BASE_DIR=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")

if [ -z "$TEST_REPO_DIR" ]; then
  echo "Error: TEST_REPO_DIR is not set."
  exit 1
fi

if [ -z "$OUTPUT_TOKEN_FILE" ]; then
  echo "Error: OUTPUT_TOKEN_FILE is not set."
  exit 1
fi



cd $TEST_REPO_DIR/testing/e2e-tracetesting

if [[ "$*" != *"--skip-playwright"* ]]; then
  npm install
  npx playwright test tests/setup/extract-default-token.manual.ts --grep '@manual'
fi

############################################
############################################

cd $BASE_DIR

# run script for initial configuration

export VARS_TOKEN=$(cat $OUTPUT_TOKEN_FILE | jq -r '.token')
sed -i.bkp 's/%TOKEN_PLACEHOLDER%/'"$VARS_TOKEN"'/g' tests/vars/ci.yaml

export VARS_ORG_ID=$(cat $OUTPUT_TOKEN_FILE | jq -r '.orgId')
sed -i.bkp 's/%ORG_ID_PLACEHOLDER%/'"$VARS_ORG_ID"'/g' tests/vars/ci.yaml

export VARS_ENV_ID=$(cat $OUTPUT_TOKEN_FILE | jq -r '.envId')
sed -i.bkp 's/%ENV_ID_PLACEHOLDER%/'"$VARS_ENV_ID"'/g' tests/vars/ci.yaml

export VARS_COOKIE=$(cat $OUTPUT_TOKEN_FILE | jq -r '.cookieHeader' | sed 's/[&/\]/\\&/g')
sed -i.bkp 's/%COOKIE_PLACEHOLDER%/'"$VARS_COOKIE"'/g' tests/vars/ci.yaml

export VARS_INVITE_EMAIL=$(cat $OUTPUT_TOKEN_FILE | jq -r '.inviteEmail')
sed -i.bkp 's/%INVITE_EMAIL_PLACEHOLDER%/'"$VARS_INVITE_EMAIL"'/g' tests/vars/ci.yaml