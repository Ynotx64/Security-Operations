#!/usr/bin/env bash
set -euo pipefail

echo "=== Zeek current logs grep watch ==="
while true; do
  sudo grep -R "APTPACK\|APT-PACK" /opt/zeek/logs/current 2>/dev/null || true
  sleep 5
  clear
done
