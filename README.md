# VPS setup variables and config
## inventory.ini
### Replace IPs with your actual VPS IPs

-----

## group_vars/all.yml - Encrypted with ansible-vault

### Create this file with: ansible-vault create group_vars/all.yml

# SSH Configuration

vault_ssh_port: “2222”

# Admin User Configuration

vault_admin_username: “adminuser”
vault_admin_password: “SecurePassword123!”

# Additional secure credentials can be added here

vault_fail2ban_email: “admin@yourdomain.com”
vault_timezone: “UTC”

-----
