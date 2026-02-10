---
name: vps-openclaw-security-hardening
description: Production-ready security hardening for VPS running OpenClaw AI agents. Includes SSH hardening, firewall, audit logging, credential management, and intelligent alerting. Follows BSI IT-Grundschutz and NIST guidelines with minimal resource overhead.
version: 1.0.0
author: OpenClaw Community
homepage: https://github.com/openclaw/skills/tree/main/skills/vps-openclaw-security-hardening
metadata:
  openclaw:
    emoji: 🛡️
    requires:
      bins: ["ssh", "ufw", "auditd", "systemctl", "apt-get"]
      os: ["linux"]
    tags: ["security", "hardening", "vps", "audit", "monitoring", "firewall", "ssh"]
    install: "./scripts/install.sh"
    verify: "./scripts/verify.sh"
---

# VPS Security Hardening for OpenClaw

Production-ready security hardening for AI agent deployments on VPS.

## Quick Start

```bash
# Install
cd ~/.openclaw/skills/vps-openclaw-security-hardening
sudo ./scripts/install.sh

# Verify
./scripts/verify.sh

# Test SSH (new terminal)
ssh -p 6262 root@your-vps-ip
```

## What It Does

| Layer | Protection | Implementation |
|-------|------------|----------------|
| **Network** | Firewall, SSH hardening | UFW, port 6262, key-only |
| **System** | Auto-updates, monitoring | unattended-upgrades, auditd |
| **Secrets** | Credential management | Centralized .env, 600 permissions |
| **Monitoring** | Audit logging, alerting | Kernel-level audit, Telegram |

## Requirements

- Ubuntu 20.04+ or Debian 11+
- Root access
- Existing SSH key authentication
- Telegram bot (optional, for alerts)

## Security Changes

### SSH
- Port: 22 → 6262
- Auth: Keys only (no passwords)
- Root login: Disabled
- Max retries: 3

### Firewall
- Default: Deny incoming
- Allow: Port 6262 only

### Monitoring
- Credential file access tracking
- SSH config change detection
- Privilege escalation alerts
- Daily security briefing

## Resource Usage

| Component | RAM | Disk |
|-----------|-----|------|
| Auditd | ~2 MB | 40 MB max |
| UFW | ~1 MB | Negligible |
| Scripts | ~5 MB | Negligible |
| **Total** | **<10 MB** | **<50 MB** |

## Files

- `scripts/install.sh` - Main installation
- `scripts/verify.sh` - Verify installation
- `scripts/rollback-ssh.sh` - Emergency rollback
- `scripts/critical-alert.sh` - Telegram alerts
- `scripts/daily-briefing.sh` - Daily reports
- `rules/audit.rules` - Audit configuration

## Documentation

See [README.md](README.md) for full documentation.

## License

MIT - See LICENSE file
