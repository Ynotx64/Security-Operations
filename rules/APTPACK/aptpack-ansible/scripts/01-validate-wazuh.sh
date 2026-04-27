#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "=== Wazuh manager status ==="
sudo /var/ossec/bin/wazuh-control status || true

echo
echo "=== Wazuh analysis/rule validation ==="
if [ -x /var/ossec/bin/wazuh-analysisd ]; then
  sudo /var/ossec/bin/wazuh-analysisd -t || true
elif [ -x /var/ossec/bin/ossec-analysisd ]; then
  sudo /var/ossec/bin/ossec-analysisd -t || true
else
  echo "No Wazuh analysis validation binary found"
fi

echo
echo "=== Recent Wazuh manager log ==="
sudo tail -n 80 "$WAZUH_LOG" || true

echo
echo "=== Recent alert hits for APTPACK ==="
sudo grep -E 'APTPACK|aptpack_' "$WAZUH_ALERTS" 2>/dev/null | tail -n 50 || true

echo
echo "=== Dashboard searches ==="
cat <<SEARCHES
$IA_CORR_ID
$IA_ANTI_ID
$EXEC_CORR_ID
$EXEC_ANTI_ID
$PE_CORR_ID
$PE_ANTI_ID
$DISC_CORR_ID
$DISC_ANTI_ID
$CA_CORR_ID
$CA_ANTI_ID
$STAGE_CORR_ID
$STAGE_ANTI_ID
SEARCHES
