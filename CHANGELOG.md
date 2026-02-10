# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-10

### Added
- Initial release of VPS Security Hardening skill
- SSH hardening: custom port (6262), key-only auth, root disabled
- UFW firewall: default deny, SSH port only
- Auditd logging: credential monitoring, SSH config tracking
- Automatic updates via unattended-upgrades
- Telegram alerting for critical security events
- Daily security briefing with risk scoring
- Resource-conscious design (<30MB RAM, <50MB disk)
- Complete documentation and troubleshooting guide
- Verification and rollback scripts

### Security
- Implements BSI IT-Grundschutz controls
- Follows NIST Cybersecurity Framework
- Defense-in-depth architecture

[1.0.0]: https://github.com/openclaw/skills/releases/tag/vps-security-hardening-v1.0.0
