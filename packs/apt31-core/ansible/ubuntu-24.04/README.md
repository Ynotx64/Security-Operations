# Ubuntu 24.04 Hardening

This Ansible content hardens Ubuntu 24.04 systems that support identity, admin, SIEM, and utility workflows relevant to APT31-style credential-led intrusion detection.

## What it enforces

- unattended security upgrades
- fail2ban for SSH
- auditd and rsyslog baseline
- SSH root login disabled
- SSH password authentication disabled
- UFW default deny inbound
- allowlisted SSH source ranges
- optional osquery package support placeholder
