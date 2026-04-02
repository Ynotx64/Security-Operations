#!/usr/bin/env bash
set -euo pipefail

echo "[*] XRDP service state"
systemctl status xrdp --no-pager || true

echo "[*] Recent XRDP log entries"
sudo tail -n 50 /var/log/xrdp-sesman.log 2>/dev/null || echo "No xrdp-sesman log found"

echo "[*] UFW status"
sudo ufw status verbose || true

echo "[*] Fail2ban status"
sudo fail2ban-client status 2>/dev/null || echo "Fail2ban not available"
