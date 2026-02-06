#!/bin/bash
set -eux

# Update system (NO UPGRADE)
apt-get update -y

# Install prerequisites
apt-get install -y \
  software-properties-common \
  python3 \
  python3-pip \
  git

# Python deps for aws_ec2 inventory
pip3 install boto3 botocore

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Create ansible working dir
mkdir -p /home/ubuntu/ansible
chown -R ubuntu:ubuntu /home/ubuntu/ansible

