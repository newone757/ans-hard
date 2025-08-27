# VPS setup variables and config

To run the playbook:
1. Run setup.sh
2. Edit inventory.ini with your VPS IPs
3. Edit/Create vault: "ansible-vault edit group_vars/all.yml"
4. Run: "ansible-playbook -i inventory.ini vps-setup.yml –ask-vault-pass"

-----

```
---
## group_vars/all.yml - Encrypted with ansible-vault

### Create this file with: ansible-vault create group_vars/all.yml

# SSH Configuration

vault_ssh_port: “2222”

# Admin User Configuration

vault_admin_username: “adminuser”
vault_admin_password: “SecurePassword123!”

# Additional secure credentials can be added here

vault_fail2ban_email: “admin@yourdomain.com”
vault_timezone: “UTC”```

-----
