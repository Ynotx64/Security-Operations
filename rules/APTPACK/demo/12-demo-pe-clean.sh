#!/usr/bin/env bash
set -euo pipefail

PE_CORR_ID="APTPACK-PE-CORR-001"
PE_ANTI_ID="APTPACK-PE-ANTI-001"

echo "=== PE correlation: cron persistence marker ==="
logger "{\"event_type\":\"aptpack_pe_test\",\"artifact\":\"cron\",\"value\":\"@reboot /usr/local/bin/system-update-helper --background\",\"test_id\":\"$PE_CORR_ID\",\"phase\":\"PE\",\"severity\":\"high\"}"

echo "=== PE anti-bypass: fake service marker ==="
logger "{\"event_type\":\"aptpack_pe_bypass\",\"service\":\"system-update-helper.service\",\"action\":\"enable-start\",\"test_id\":\"$PE_ANTI_ID\",\"phase\":\"PE\",\"severity\":\"high\"}"

echo "=== PE service command markers ==="
logger "{\"event_type\":\"aptpack_pe_service_cmd\",\"cmd\":\"systemctl enable --now system-update-helper.service\",\"test_id\":\"$PE_CORR_ID\",\"phase\":\"PE\"}"
logger "{\"event_type\":\"aptpack_pe_cron_cmd\",\"cmd\":\"echo '@reboot /usr/local/bin/system-update-helper --background' >> /etc/crontab\",\"test_id\":\"$PE_CORR_ID\",\"phase\":\"PE\"}"

sleep 2

echo
echo "=== journalctl verification ==="
journalctl --since "2 minutes ago" --no-pager | grep -E 'APTPACK-PE|aptpack_pe|system-update-helper|@reboot' || true

echo
echo "=== syslog verification ==="
grep -E 'APTPACK-PE|aptpack_pe|system-update-helper|@reboot' /var/log/syslog 2>/dev/null | tail -n 20 || true

echo
echo "=== dashboard search terms ==="
echo "APTPACK-PE-CORR-001"
echo "APTPACK-PE-ANTI-001"
echo "aptpack_pe_test"
echo "aptpack_pe_bypass"
echo "system-update-helper.service"
echo "@reboot /usr/local/bin/system-update-helper --background"
