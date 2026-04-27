#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "=== CA correlation event: beaconing ==="
for i in 1 2 3 4 5; do
  curl -A "APT-PACK-CA-BEACON" \
    "http://$TARGET/beacon?test_id=$CA_CORR_ID" >/dev/null || true
  echo "beacon $i"
  sleep 10
done

echo
echo "=== CA anti-bypass event: jitter beacon ==="
for i in 1 2 3 4 5; do
  curl -A "APT-PACK-CA-JITTER" \
    "http://$TARGET/jitter?test_id=$CA_ANTI_ID" >/dev/null || true
  echo "jitter $i"
  sleep $((RANDOM%10+5))
done

echo
echo "=== Dashboard search terms ==="
echo "$CA_CORR_ID"
echo "$CA_ANTI_ID"
echo "APT-PACK-CA-BEACON"
echo "APT-PACK-CA-JITTER"
