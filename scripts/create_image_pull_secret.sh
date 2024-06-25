#!/bin/bash

# Prompt for GitHub username
read -p $'\e[1;32m Enter your GitHub username:\e[0m ' GITHUB_USERNAME

# Prompt for GitHub token

# Prompt for GitHub token requirements
cat <<EOF
Please provide a GitHub personal access token with the following requirements:
- The token should have the "read:packages" scope to access GitHub Container Registry.

To create a personal access token go to https://github.com/settings/tokens

For more information, see: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
EOF

read -s -p $'\e[1;32m Enter your GitHub personal access token:\e[0m ' GITHUB_TOKEN
echo

# Create the ImagePullSecret in Kubernetes
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=$GITHUB_USERNAME \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=your-email@example.com

# Check if the secret was created successfully
if [ $? -eq 0 ]; then
  printf "\e[42mImagePullSecret created successfully.\e[0m\n"
else
  printf "\e[41mError creating the ImagePullSecret.\e[0m\n"
  exit 1
fi
