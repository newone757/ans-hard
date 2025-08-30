# VPS Hardening Playbook with Vault Management

## Overview

This enhanced Ansible playbook provides automated VPS hardening with intelligent detection of server state, vault-based credential management, and automatic Fail2Ban whitelist management during setup.

## Features

### Smart Server Detection
- **Automatic State Detection**: The playbook automatically detects if a server is:
  - **Fresh**: Never configured (connects as root on port 22)
  - **Configured**: Already hardened (connects as admin user on custom port)
  - **Unknown**: Cannot connect (skipped)
  
- **Intelligent Connection Handling**: Uses appropriate credentials based on server state
- **No Manual Intervention**: Automatically switches between root and admin user

### Security Features
- **Vault Management**: All sensitive data (passwords, usernames, ports) stored encrypted
- **SSH Hardening**: Custom port, key-only auth, disabled root login
- **Fail2Ban Protection**: Automatic whitelist management during setup
- **UFW Firewall**: Configured with minimal required ports
- **Kernel Hardening**: Security-focused sysctl parameters
- **Automatic Updates**: Unattended security updates configured
- **Intrusion Detection**: AIDE, rkhunter, chkrootkit installed

### Fail2Ban Whitelist Management
- **Automatic Detection**: Identifies control node IP automatically
- **Temporary Whitelist**: Adds control node during setup to prevent lockout
- **Automatic Cleanup**: Removes whitelist after configuration complete
- **Graceful Handling**: Works whether Fail2Ban is installed or not

## Directory Structure

```
.
├── vps-setup.yml           # Main playbook
├── inventory.ini           # Server inventory
├── setup.sh               # Helper script
├── group_vars/
│   └── all/
│       └── vault.yml      # Encrypted vault file
└── host_vars/             # Optional host-specific variables
```

## Quick Start

### 1. Prerequisites

Install Ansible on your control machine:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install ansible

# RHEL/CentOS
sudo yum install ansible

# MacOS
brew install ansible
```

### 2. Initial Setup

```bash
# Make the setup script executable
chmod +x setup.sh

# Run the setup script
./setup.sh

# Select option 1 for initial setup
```

### 3. Configure Your Servers

Edit `inventory.ini`:

```ini
[vps_servers]
vps1 ansible_host=192.168.1.10 vault_root_password="{{ vault_root_passwords.vps1 }}"
vps2 ansible_host=192.168.1.11 vault_root_password="{{ vault_root_passwords.vps2 }}"
```

### 4. Set Up Vault Variables

Edit the vault file:

```bash
ansible-vault edit group_vars/all/vault.yml
```

Add your configuration:

```yaml
vault_ssh_port: 2222  # Choose a custom port
vault_admin_username: sysadmin
vault_admin_password: "StrongP@ssw0rd!"

vault_root_passwords:
  vps1: "root_password_for_vps1"
  vps2: "root_password_for_vps2"
```

### 5. Run the Playbook

```bash
# Test connectivity first
ansible all -i inventory.ini -m ping --ask-vault-pass

# Dry run (check mode)
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass --check

# Actual run
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass
```

## Playbook Workflow

### Phase 1: Detection
1. Attempts connection on custom port as admin user
2. Falls back to standard port as root
3. Determines server state (fresh/configured/unknown)
4. Sets appropriate connection parameters

### Phase 2: Initial Setup (Fresh Servers Only)
1. Creates admin user with sudo privileges
2. Configures SSH phase 1 (allows both root and admin)
3. Tests new configuration
4. Temporarily whitelists control node in Fail2Ban

### Phase 3: Hardening (All Servers)
1. Completes SSH hardening (disables root, passwords)
2. Configures UFW firewall
3. Sets up Fail2Ban with proper jails
4. Applies kernel security parameters
5. Installs security tools (AIDE, rkhunter, etc.)
6. Configures automatic updates

### Phase 4: Cleanup
1. Removes control node from Fail2Ban whitelist
2. Verifies all configurations
3. Generates security report

## Advanced Usage

### Running on Mixed Environments

The playbook handles mixed environments automatically:

```bash
# Mix of fresh and already-configured servers
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass
```

### Custom Variables Per Host

Create host-specific variables in `host_vars/`:

```bash
# host_vars/vps1/vars.yml
custom_ssh_port: 2223
custom_admin_user: admin1
```

### Limiting Execution to Specific Hosts

```bash
# Only run on vps1
ansible-playbook -i inventory.ini vps-setup.yml --limit vps1 --ask-vault-pass

# Run on multiple specific hosts
ansible-playbook -i inventory.ini vps-setup.yml --limit "vps1,vps2" --ask-vault-pass
```

### Verbose Output for Debugging

```bash
# Increasing verbosity levels
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass -v    # Basic
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass -vv   # More detail
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass -vvv  # Full debug
```

## Security Considerations

### Vault Password Management
- Use a strong vault password
- Consider using a password manager
- Never commit vault passwords to version control
- Optional: Use `ansible-vault` password file (secured with proper permissions)

### SSH Key Security
- The playbook generates a dedicated management key
- Store private keys securely
- Consider using SSH agent forwarding
- Rotate keys periodically

### Post-Setup Recommendations
1. **Review Security Report**: Check `~/security-report.txt` on each server
2. **Monitor Logs**: Regular review of `/var/log/auth.log` and fail2ban logs
3. **Test Access**: Verify SSH access works before closing root sessions
4. **Backup Configuration**: Save your vault file and SSH keys securely
5. **Regular Audits**: Run `lynis audit system` periodically

## Troubleshooting

### Connection Issues

```bash
# Test basic connectivity
ansible all -i inventory.ini -m ping --ask-vault-pass

# Test with specific user and port
ansible all -i inventory.ini -m ping -e "ansible_port=2222" -e "ansible_user=sysadmin" --ask-vault-pass
```

### Locked Out by Fail2Ban

If you get locked out:

1. **Console Access**: Use VPS provider's console
2. **Unban IP**: `sudo fail2ban-client set sshd unbanip YOUR.IP.ADD.RESS`
3. **Check Status**: `sudo fail2ban-client status sshd`

### Vault Issues

```bash
# Forgotten vault password - re-encrypt
ansible-vault rekey group_vars/all/vault.yml

# View vault contents (encrypted)
ansible-vault view group_vars/all/vault.yml

# Decrypt permanently (not recommended)
ansible-vault decrypt group_vars/all/vault.yml
```

### SSH Key Problems

```bash
# Regenerate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vps_management_key -C "VPS Management Key"

# Test SSH connection manually
ssh -i ~/.ssh/vps_management_key -p 2222 sysadmin@server_ip
```

## Maintenance

### Adding New Servers

1. Add to `inventory.ini`:
   ```ini
   vps3 ansible_host=192.168.1.12 vault_root_password="{{ vault_root_passwords.vps3 }}"
   ```

2. Add root password to vault:
   ```bash
   ansible-vault edit group_vars/all/vault.yml
   ```

3. Run playbook for new server only:
   ```bash
   ansible-playbook -i inventory.ini vps-setup.yml --limit vps3 --ask-vault-pass
   ```

### Updating Security Configuration

For already-configured servers, the playbook will:
- Skip user creation and initial SSH setup
- Update security packages
- Apply any new hardening rules
- Maintain existing configurations

```bash
# Update all configured servers
ansible-playbook -i inventory.ini vps-setup.yml --ask-vault-pass
```

## Best Practices

1. **Version Control**: 
   - Commit playbooks and inventory (not vault files!)
   - Use `.gitignore` for sensitive files

2. **Backup Strategy**:
   - Keep encrypted backups of vault files
   - Store SSH keys in secure location
   - Document your setup

3. **Regular Updates**:
   - Run playbook periodically for updates
   - Review and update security configurations
   - Monitor for new security best practices

4. **Testing**:
   - Always test on non-production servers first
   - Use check mode before actual runs
   - Maintain staging environment

## Support and Contribution

For issues, improvements, or questions:
- Review the playbook output carefully
- Check system logs on target servers
- Test connectivity and credentials
- Verify network access and firewall rules

Remember: Security is an ongoing process, not a one-time setup!
