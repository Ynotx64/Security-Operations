#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "=== IA correlation event ==="
curl -v -A "APT-PACK-IA-TEST-UA" \
  "http://$TARGET/login.php?phase=ia&test_id=$IA_CORR_ID" || true

echo
echo "=== IA anti-bypass event ==="
curl -v -A "APT-PACK-IA-EVASION" \
  -H "X-Forwarded-For: 127.0.0.1" \
  "http://$TARGET/admin?test_id=$IA_ANTI_ID" || true

echo
echo "=== Dashboard search terms ==="
echo "$IA_CORR_ID"
echo "$IA_ANTI_ID"
echo "APT-PACK-IA-TEST-UA"
echo "APT-PACK-IA-EVASION"
