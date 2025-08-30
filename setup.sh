#!/bin/bash

# VPS Ansible Setup Script
# This script helps you set up the directory structure and run the playbook

set -e

echo "==================================="
echo "VPS Ansible Hardening Setup Script"
echo "==================================="

# Create directory structure
create_directory_structure() {
    echo "Creating directory structure..."
    mkdir -p group_vars/all
    mkdir -p host_vars
    mkdir -p roles
    echo "✓ Directory structure created"
}

# Create vault file
create_vault_file() {
    if [ ! -f "group_vars/all/vault.yml" ]; then
        echo ""
        echo "Creating encrypted vault file..."
        echo "You will be prompted to enter a vault password."
        echo "Remember this password - you'll need it to run the playbook!"
        
        EDITOR=nano ansible-vault create group_vars/all/vault.yml
        
        echo "✓ Vault file created"
        echo ""
        echo "Edit the vault file with your actual values using:"
        echo "  ansible-vault edit group_vars/all/vault.yml"
    else
        echo "✓ Vault file already exists"
    fi
}

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if ansible is installed
    if ! command -v ansible &> /dev/null; then
        echo "❌ Ansible is not installed. Please install it first:"
        echo "  Ubuntu/Debian: sudo apt-get install ansible"
        echo "  RHEL/CentOS: sudo yum install ansible"
        echo "  MacOS: brew install ansible"
        exit 1
    fi
    
    # Check if ansible-vault is available
    if ! command -v ansible-vault &> /dev/null; then
        echo "❌ ansible-vault is not available. Please install ansible."
        exit 1
    fi
    
    echo "✓ All prerequisites met"
}

# Generate SSH key if it doesn't exist
generate_ssh_key() {
    if [ ! -f ~/.ssh/vps_management_key ]; then
        echo ""
        echo "Generating SSH management key..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/vps_management_key -C "VPS Management Key" -N ""
        echo "✓ SSH key generated at ~/.ssh/vps_management_key"
    else
        echo "✓ SSH management key already exists"
    fi
}

# Run the playbook
run_playbook() {
    echo ""
    echo "Ready to run the playbook!"
    echo ""
    echo "Choose an option:"
    echo "1) Dry run (check mode - no changes will be made)"
    echo "2) Run playbook (will make actual changes)"
    echo "3) Run with verbose output"
    echo "4) Exit"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            echo "Running in check mode..."
            ansible-playbook -i inventory.ini vps-harden.yml --ask-vault-pass --check
            ;;
        2)
            echo "Running playbook..."
            ansible-playbook -i inventory.ini vps-harden.yml --ask-vault-pass
            ;;
        3)
            echo "Running playbook with verbose output..."
            ansible-playbook -i inventory.ini vps-harden.yml --ask-vault-pass -vv
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Main menu
main_menu() {
    echo ""
    echo "What would you like to do?"
    echo "1) Initial setup (create directories, vault, SSH keys)"
    echo "2) Edit vault file"
    echo "3) Edit inventory file"
    echo "4) Run playbook"
    echo "5) Test connectivity to servers"
    echo "6) Show current configuration"
    echo "7) Exit"
    
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            check_prerequisites
            create_directory_structure
            generate_ssh_key
            create_vault_file
            echo ""
            echo "✓ Initial setup complete!"
            echo ""
            echo "Next steps:"
            echo "1. Edit inventory.ini with your server IPs"
            echo "2. Edit the vault file: ansible-vault edit group_vars/all/vault.yml"
            echo "3. Run the playbook"
            main_menu
            ;;
        2)
            if [ ! -f "group_vars/all/vault.yml" ]; then
                echo "Vault file doesn't exist. Run initial setup first."
            else
                EDITOR=nano ansible-vault edit group_vars/all/vault.yml
            fi
            main_menu
            ;;
        3)
            ${EDITOR:-nano} inventory.ini
            main_menu
            ;;
        4)
            if [ ! -f "vps-harden.yml" ]; then
                echo "❌ vps-setup.yml not found in current directory"
                exit 1
            fi
            if [ ! -f "inventory.ini" ]; then
                echo "❌ inventory.ini not found in current directory"
                exit 1
            fi
            run_playbook
            ;;
        5)
            echo "Testing connectivity to all servers..."
            ansible all -i inventory.ini -m ping  --ask-vault-pass -u root
            main_menu
            ;;
        6)
            echo ""
            echo "Current Configuration:"
            echo "====================="
            if [ -f "inventory.ini" ]; then
                echo "Inventory file exists ✓"
                echo "Servers defined:"
                grep -E "^\w+" inventory.ini | grep ansible_host | cut -d' ' -f1 | while read server; do
                    echo "  - $server"
                done
            else
                echo "Inventory file not found ✗"
            fi
            
            if [ -f "group_vars/all/vault.yml" ]; then
                echo "Vault file exists ✓"
            else
                echo "Vault file not found ✗"
            fi
            
            if [ -f "~/.ssh/vps_management_key" ]; then
                echo "SSH management key exists ✓"
            else
                echo "SSH management key not found ✗"
            fi
            
            main_menu
            ;;
        7)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice"
            main_menu
            ;;
    esac
}

# Start the script
echo ""
check_prerequisites
main_menu
