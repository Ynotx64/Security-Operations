#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "=== PE correlation event ==="
logger "{\"event_type\":\"aptpack_pe_test\",\"artifact\":\"cron\",\"value\":\"@reboot /tmp/.aptpack\",\"test_id\":\"$PE_CORR_ID\",\"phase\":\"PE\"}"

echo "=== PE anti-bypass event ==="
logger "{\"event_type\":\"aptpack_pe_bypass\",\"service\":\"system-update-helper\",\"action\":\"persist\",\"test_id\":\"$PE_ANTI_ID\",\"phase\":\"PE\"}"

sleep 2

echo
echo "=== journalctl verification ==="
journalctl -n 50 | grep -E 'APTPACK-PE|aptpack_pe' || true

echo
echo "=== syslog verification ==="
grep -E 'APTPACK-PE|aptpack_pe' /var/log/syslog 2>/dev/null | tail -n 20 || true

echo
echo "=== Wazuh alerts verification ==="
sudo grep -E 'APTPACK-PE|aptpack_pe' /var/ossec/logs/alerts/alerts.json 2>/dev/null | tail -n 20 || true

echo
echo "=== Dashboard search terms ==="
echo "$PE_CORR_ID"
echo "$PE_ANTI_ID"
echo "aptpack_pe_test"
echo "aptpack_pe_bypass"
