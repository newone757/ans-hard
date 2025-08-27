#!/bin/bash
set -e

echo "Setting up Ansible VPS Management Environment"

# Create directory structure

mkdir -p group_vars host_vars

# Install required collections

ansible-galaxy collection install -r requirements.yml

# Create vault file if it doesn’t exist

if [ ! -f group_vars/all.yml ]; then
echo "Creating encrypted vault file…"
ansible-vault create group_vars/all.yml
echo "Please add your vault variables to group_vars/all.yml"
fi

# Generate SSH key if it doesn’t exist

if [ ! -f ~/.ssh/vps_management_key ]; then
echo "Generating SSH key for VPS management…"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vps_management_key -C "VPS Management Key"
fi

echo "Setup complete!"
echo ""
echo “To run the playbook:”
echo “1. Edit inventory.ini with your VPS IPs”
echo “2. Run: ansible-playbook -i inventory.ini vps-setup.yml –ask-vault-pass”
echo “”
echo “To edit vault: ansible-vault edit group_vars/all.yml”
