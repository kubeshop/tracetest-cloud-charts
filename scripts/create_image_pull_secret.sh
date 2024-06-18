#!/bin/bash

# Prompt for GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

# Prompt for GitHub token

# Prompt for GitHub token requirements
cat <<EOF
Please provide a GitHub personal access token with the following requirements:
- The token should have the "read:packages" scope to access GitHub Container Registry.

For more information, see: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
EOF

read -s -p "Enter your GitHub personal access token: " GITHUB_TOKEN
echo

# Create the ImagePullSecret in Kubernetes
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=$GITHUB_USERNAME \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=your-email@example.com

# Check if the secret was created successfully
if [ $? -eq 0 ]; then
  echo "ImagePullSecret created successfully."
else
  echo "Error creating the ImagePullSecret."
  exit 1
fi
