#!/bin/bash
# Emergency SSH Rollback Script
# Usage: ./rollback-ssh.sh
# Restores SSH to port 22 with password authentication (emergency only!)

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   EMERGENCY SSH ROLLBACK                       ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}WARNING:${NC} This will:"
echo "  1. Restore SSH to port 22"
echo "  2. Re-enable password authentication"
echo "  3. Remove custom security settings"
echo ""
echo "Only use if you're locked out of the server!"
echo ""

read -p "Are you sure? Type 'ROLLBACK' to confirm: " confirm
if [[ "$confirm" != "ROLLBACK" ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "Creating backup of current config..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.rollback.$(date +%s)

echo "Restoring default SSH configuration..."

# Remove custom settings
sed -i '/^Port /d' /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/^MaxAuthTries/d' /etc/ssh/sshd_config
sed -i '/^ClientAliveInterval/d' /etc/ssh/sshd_config
sed -i '/^ClientAliveCountMax/d' /etc/ssh/sshd_config
sed -i '/^X11Forwarding/d' /etc/ssh/sshd_config

# Add safe defaults
cat <> /etc/ssh/sshd_config

# Emergency rollback configuration
Port 22
PermitRootLogin yes
PasswordAuthentication yes
EOF

echo "Testing configuration..."
if /usr/sbin/sshd -t; then
    echo -e "${GREEN}✓ Config valid${NC}"
else
    echo -e "${RED}✗ Config test failed!${NC}"
    echo "Restoring from backup..."
    cp /etc/ssh/sshd_config.bak.* /etc/ssh/sshd_config 2>/dev/null || true
    exit 1
fi

echo "Restarting SSH..."
systemctl restart sshd

echo "Updating firewall..."
ufw allow 22/tcp comment 'SSH emergency rollback'
ufw delete allow 6262/tcp 2>/dev/null || true

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ROLLBACK COMPLETE                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo "SSH is now accessible on port 22 with password authentication."
echo ""
echo "Next steps:"
echo "  1. Test: ssh root@your-server-ip"
echo "  2. Re-run hardening when ready"
echo ""
echo "Backup saved to: /etc/ssh/sshd_config.rollback.*"
