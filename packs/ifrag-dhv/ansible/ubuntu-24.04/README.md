# Ubuntu 24.04 Hardening

This Ansible content hardens Ubuntu 24.04 systems that provide XRDP, bastion, or remote administration support functions.

## What it enforces

- Installs required packages for logging and firewall management
- Enables unattended security upgrades
- Disables direct root SSH login
- Disables password authentication for SSH by default
- Enforces UFW default deny inbound
- Restricts RDP and SSH access to approved source networks
- Ensures XRDP is installed only when explicitly enabled
- Enables audit logging support
- Optionally disables XRDP entirely when not required
