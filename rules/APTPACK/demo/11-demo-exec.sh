#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "=== EXEC correlation event ==="
logger "{\"event_type\":\"aptpack_exec_test\",\"cmd\":\"powershell -enc QUFQVFBBQ0s=\",\"test_id\":\"$EXEC_CORR_ID\",\"phase\":\"EXEC\"}"

echo "=== EXEC anti-bypass event ==="
logger "{\"event_type\":\"aptpack_exec_bypass\",\"cmd\":\"bash -c eval echo bypass\",\"test_id\":\"$EXEC_ANTI_ID\",\"phase\":\"EXEC\"}"

sleep 2

echo
echo "=== journalctl verification ==="
journalctl -n 50 | grep -E 'APTPACK-EXEC|aptpack_exec' || true

echo
echo "=== syslog verification ==="
grep -E 'APTPACK-EXEC|aptpack_exec' /var/log/syslog 2>/dev/null | tail -n 20 || true

echo
echo "=== Wazuh alerts verification ==="
sudo grep -E 'APTPACK-EXEC|aptpack_exec' /var/ossec/logs/alerts/alerts.json 2>/dev/null | tail -n 20 || true

echo
echo "=== Dashboard search terms ==="
echo "$EXEC_CORR_ID"
echo "$EXEC_ANTI_ID"
echo "aptpack_exec_test"
echo "aptpack_exec_bypass"
