#!/usr/bin/env bash
set -euo pipefail

#####################################
# Configuration
#####################################

ENVIRONMENT="${1:-dev}"

# Resolve project root safely
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TERRAFORM_DIR="$PROJECT_ROOT/terra-config"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

KEY_PATH="$ANSIBLE_DIR/ansible_keypair.pem"

#####################################
# Phase 0 – Local sanity checks
#####################################

echo "======================================"
echo " Deploying environment: $ENVIRONMENT"
echo "======================================"

echo "Running local sanity checks..."

command -v terraform >/dev/null || { echo "❌ Terraform not installed"; exit 1; }
command -v ansible >/dev/null || { echo "❌ Ansible not installed"; exit 1; }
command -v aws >/dev/null || { echo "❌ AWS CLI not installed"; exit 1; }

aws sts get-caller-identity >/dev/null || {
  echo "❌ AWS credentials not configured"
  exit 1
}

#####################################
# Phase 1 – Terraform
#####################################

echo "Running Terraform..."
cd "$TERRAFORM_DIR"

terraform init -upgrade
terraform validate

terraform apply -auto-approve \
  -var="environment=$ENVIRONMENT"

#####################################
# Phase 2 – Post-Terraform validation
#####################################

echo "Validating SSH key created by Terraform..."

if [[ ! -f "$KEY_PATH" ]]; then
  echo "❌ Private key not found at:"
  echo "   $KEY_PATH"
  echo "Terraform was expected to create it."
  exit 1
fi

chmod 400 "$KEY_PATH"

echo "Private key found and permissions set."

echo "Waiting for EC2 instances to become reachable..."
echo "Waiting for SSH to become available on all nodes..."

for host in $(ansible-inventory -i ansible/inventory/aws_ec2.yml --list \
  | jq -r '.aws_ec2.hosts[]'); do
  echo "Waiting for $host..."
  until ssh -o StrictHostKeyChecking=no \
            -o ConnectTimeout=5 \
            -i ansible/ansible_keypair.pem \
            ubuntu@$host 'echo SSH_READY' >/dev/null 2>&1; do
    sleep 60
  done
done

echo "All hosts reachable via SSH"


#####################################
# Phase 3 – Ansible
#####################################

cd "$ANSIBLE_DIR"

echo "Validating Ansible inventory..."
ansible-inventory -i inventory/aws_ec2.yml --graph

echo "Running Ansible playbook..."
ansible-playbook playbook.yml

#####################################
# Done
#####################################

echo "======================================"
echo " Deployment completed successfully"
echo "======================================"

#############################################################################

# #!/bin/bash
# # set -euo pipefail

# # KEY_NAME="ansible-key"
# # SSH_CIDR="$(curl -4 -s ifconfig.me)/32"
# # VPC_ID="vpc-09f4ce04bc98e9123"

# # cd terra-config
# # terraform init
# # terraform apply -auto-approve \
# #   -var="key_name=${KEY_NAME}" \
# #   -var="vpc_id=${VPC_ID}" \
# #   -var="allowed_ssh_cidr=${SSH_CIDR}"

# # CONTROLLER_IP=$(terraform output -raw controller_public_ip)
# # cd ..
# # echo "Waiting for SSH on controller (${CONTROLLER_IP})..."

# # until ssh -o StrictHostKeyChecking=no \
# #           -o ConnectTimeout=5 \
# #           ubuntu@${CONTROLLER_IP} "echo SSH ready" >/dev/null 2>&1
# # do
# #   sleep 30
# # done
# # scp -r ansible ubuntu@${CONTROLLER_IP}:/opt/ansible
# # ssh ubuntu@${CONTROLLER_IP} << 'EOF'
# # cd /opt/ansible
# # ansible-galaxy collection install -r requirements.yml
# # ansible-playbook playbook.yml
# # EOF

# # echo -e "\n✅ Deployment complete!"

# #!/usr/bin/env bash
# set -euo pipefail

# ########################################
# # CONFIG – CHANGE ONLY IF NEEDED
# ########################################
# KEY_NAME="ansible-keypair"
# PRIVATE_KEY="/Users/josephmbatchou/Desktop/keypair/ansible-key.pem"
# SSH_USER="ubuntu"
# TERRAFORM_DIR="terra-config"
# ANSIBLE_DIR="ansible"

# ########################################
# # PRE-FLIGHT CHECKS
# ########################################
# echo "🔍 Running pre-flight checks..."

# command -v terraform >/dev/null 2>&1 || {
#   echo "❌ terraform not installed"
#   exit 1
# }

# command -v ssh >/dev/null 2>&1 || {
#   echo "❌ ssh not installed"
#   exit 1
# }

# command -v scp >/dev/null 2>&1 || {
#   echo "❌ scp not installed"
#   exit 1
# }

# if [[ ! -f "$PRIVATE_KEY" ]]; then
#   echo "❌ SSH private key not found: $PRIVATE_KEY"
#   exit 1
# fi

# chmod 600 "$PRIVATE_KEY"

# echo "✅ Pre-flight checks passed"

# ########################################
# # TERRAFORM APPLY
# ########################################
# echo "🚀 Running Terraform..."

# cd "$TERRAFORM_DIR"
# terraform init
# terraform apply -auto-approve

# CONTROLLER_IP=$(terraform output -raw controller_public_ip)
# cd ..

# echo "✅ Terraform complete"
# echo "🖥  Controller IP: $CONTROLLER_IP"

# ########################################
# # WAIT FOR SSH (CRITICAL FIX)
# ########################################
# echo "⏳ Waiting for SSH on controller..."

# echo "⏳ Waiting for controller SSH (cloud-init + reboot)..."

# for i in {1..30}; do
#   if ssh -i "$PRIVATE_KEY" \
#      -o StrictHostKeyChecking=no \
#      -o ConnectTimeout=5 \
#      "$SSH_USER@$CONTROLLER_IP" "echo SSH ready" >/dev/null 2>&1
#   then
#     echo "✅ SSH is ready"
#     break
#   fi
#   echo "⏳ Still waiting... ($i/30)"
#   sleep 10
# done


# echo "✅ SSH is ready on controller"

# #scp -i "$PRIVATE_KEY" "$SSH_USER@$CONTROLLER_IP":/home/ubuntu/.ssh/
# #chmod 400 /home/ubuntu/.ssh/ansible-key.pem

# ########################################
# # COPY ANSIBLE PROJECT
# ########################################
# echo "📦 Copying Ansible project to controller..."

# scp -i "$PRIVATE_KEY" -r "$ANSIBLE_DIR" "$SSH_USER@$CONTROLLER_IP:/home/$SSH_USER/"

# ########################################
# # RUN ANSIBLE ON CONTROLLER
# ########################################
# echo "⚙️  Running Ansible from controller..."

# ssh -i "$PRIVATE_KEY" "$SSH_USER@$CONTROLLER_IP" <<EOF
# set -e

# cd /home/$SSH_USER/$ANSIBLE_DIR

# echo "📥 Installing Ansible collections..."
# ansible-galaxy collection install -r requirements.yml

# echo "▶️  Running playbook..."
# ansible-playbook playbook.yml
# EOF

# ########################################
# # DONE
# ########################################
# echo "🎉 Deployment completed successfully!"


