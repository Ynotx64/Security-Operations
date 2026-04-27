#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

TMPFILE="/tmp/aptpack_stage_payload.txt"
echo "APTPACK STAGE TEST PAYLOAD $STAGE_CORR_ID" > "$TMPFILE"

echo "=== STAGE correlation event: direct upload ==="
curl -X POST --data-binary @"$TMPFILE" \
  "http://$TARGET/upload?test_id=$STAGE_CORR_ID" || true

echo
echo "=== STAGE anti-bypass event: chunked upload ==="
split -b 20 "$TMPFILE" /tmp/stage_chunk_
for f in /tmp/stage_chunk_*; do
  curl -X POST --data-binary @"$f" \
    "http://$TARGET/upload?test_id=$STAGE_ANTI_ID" || true
done

echo
echo "=== Dashboard search terms ==="
echo "$STAGE_CORR_ID"
echo "$STAGE_ANTI_ID"
echo "upload"
