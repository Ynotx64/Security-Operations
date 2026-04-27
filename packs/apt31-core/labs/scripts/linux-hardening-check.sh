#!/usr/bin/env bash
set -euo pipefail

echo "[*] UFW"
sudo ufw status verbose || true

echo "[*] SSH policy"
grep -E 'PermitRootLogin|PasswordAuthentication' /etc/ssh/sshd_config || true

echo "[*] Services"
systemctl status fail2ban --no-pager || true
systemctl status auditd --no-pager || true
systemctl status rsyslog --no-pager || true
