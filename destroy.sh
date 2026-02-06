#!/usr/bin/env bash
set -euo pipefail

#####################################
# Configuration
#####################################

ENVIRONMENT="${1:-dev}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terra-config"
ANSIBLE_KEY="$PROJECT_ROOT/ansible/ansible-keypair.pem"

#####################################
# Sanity checks
#####################################

echo "======================================"
echo " Destroying environment: $ENVIRONMENT"
echo "======================================"

command -v terraform >/dev/null || { echo "❌ Terraform not installed"; exit 1; }
command -v aws >/dev/null || { echo "❌ AWS CLI not installed"; exit 1; }

aws sts get-caller-identity >/dev/null || {
  echo "❌ AWS credentials not configured"
  exit 1
}

#####################################
# Terraform destroy
#####################################

cd "$TERRAFORM_DIR"

terraform destroy -auto-approve \
  -var="environment=$ENVIRONMENT"

#####################################
# Cleanup local key (optional but recommended)
#####################################

if [[ -f "$ANSIBLE_KEY" ]]; then
  echo "Removing local private key:"
  echo "  $ANSIBLE_KEY"
  rm -f "$ANSIBLE_KEY"
fi

echo "======================================"
echo " Destroy completed successfully"
echo "======================================"

###########################################################################

# #!/bin/bash
# set -euo pipefail

# echo " Terraform Infrastructure Teardown"

# # Ensure Terraform is installed
# if ! command -v terraform >/dev/null 2>&1; then
#   echo "ERROR: Terraform is not installed or not in PATH"
#   exit 1
# fi

# # Move to Terraform directory
# TERRAFORM_DIR="terra-config"

# if [ ! -d "$TERRAFORM_DIR" ]; then
#   echo "ERROR: Terraform directory '$TERRAFORM_DIR' not found"
#   exit 1
# fi

# cd "$TERRAFORM_DIR"

# # Ensure this is a Terraform project
# if [ ! -f "main.tf" ]; then
#   echo "ERROR: No main.tf found — are you in the correct directory?"
#   exit 1
# fi

# echo "Initializing Terraform..."
# terraform init -reconfigure

# echo "Destroying infrastructure..."
# terraform destroy -auto-approve

# echo "Cleanup complete."
