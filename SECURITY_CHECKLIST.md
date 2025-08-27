# VPS Security Checklist

## Pre-deployment

- [ ] Update inventory.ini with correct VPS IPs
- [ ] Create and configure vault_variables in group_vars/all.yml
- [ ] Ensure strong passwords for admin accounts
- [ ] Choose non-standard SSH port (avoid 22, 2222, 22222)

## Post-deployment verification

- [ ] SSH access works with key authentication only
- [ ] Root login is disabled
- [ ] Password authentication is disabled
- [ ] UFW firewall is active with correct rules
- [ ] Fail2Ban is running and monitoring SSH
- [ ] AIDE database is initialized
- [ ] Log monitoring is configured
- [ ] System updates are automated

## Regular maintenance

- [ ] Review fail2ban logs weekly: `fail2ban-client status sshd`
- [ ] Check AIDE reports: `cat /var/log/aide-check.log`
- [ ] Monitor auth logs: `tail -f /var/log/auth.log`
- [ ] Update SSH keys periodically
- [ ] Review firewall logs: `tail -f /var/log/ufw.log`
- [ ] Check system updates: `apt list --upgradable`

## Emergency procedures

- [ ] Keep console access to VPS (in case SSH is locked out)
- [ ] Backup SSH keys and configuration
- [ ] Document recovery procedures
- [ ] Keep ansible vault password secure but accessible

