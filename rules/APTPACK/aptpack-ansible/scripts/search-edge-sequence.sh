#!/usr/bin/env bash
set -euo pipefail

ALERTS_FILE="${1:-/var/ossec/logs/alerts/alerts.json}"
OUTDIR="${2:-$HOME/EDR-DPLY/output}"
mkdir -p "$OUTDIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "[!] jq is required"
  exit 1
fi

if [ ! -f "$ALERTS_FILE" ]; then
  echo "[!] Alerts file not found: $ALERTS_FILE"
  exit 1
fi

echo "[*] Using alerts file: $ALERTS_FILE"
echo "[*] Output dir: $OUTDIR"

RULE_IDS='["EDGE-MGMT-008","EDGE-ADM-001","EDGE-CONFIG-002","EDGE-ACCT-003","EDGE-CTRL-004","EDGE-SVC-005","EDGE-EGRESS-006","EDGE-LOG-007"]'

jq -c --argjson ids "$RULE_IDS" '
  select(.rule and .rule.id and (.rule.id as $id | $ids | index($id)))
' "$ALERTS_FILE" | tee "$OUTDIR/edge-sequence-raw.jsonl" >/dev/null

jq -r '
  [
    (.timestamp // .["@timestamp"] // "no_ts"),
    (.rule.id // "no_rule"),
    (.rule.description // "no_desc"),
    (.agent.name // .agent.id // .data.asset_hostname // .hostname // "no_host"),
    (.data.src_ip // .srcip // .src_ip // "-"),
    (.data.username // .user // .data.user // "-")
  ] | @tsv
' "$OUTDIR/edge-sequence-raw.jsonl" \
| sort \
| tee "$OUTDIR/edge-sequence-timeline.tsv" >/dev/null

echo
echo "[*] Timeline summary"
if [ -s "$OUTDIR/edge-sequence-timeline.tsv" ]; then
  column -t -s $'\t' "$OUTDIR/edge-sequence-timeline.tsv" || cat "$OUTDIR/edge-sequence-timeline.tsv"
else
  echo "[*] No matching EDGE-* alerts found in $ALERTS_FILE"
fi

echo
echo "[*] Rule counts"
if [ -s "$OUTDIR/edge-sequence-raw.jsonl" ]; then
  jq -r '.rule.id' "$OUTDIR/edge-sequence-raw.jsonl" | sort | uniq -c | sort -nr
else
  echo "[*] No matching rule hits"
fi

echo
echo "[*] Full sequence candidate by rule order"
awk -F'\t' '
{
  ts=$1; rid=$2; desc=$3; host=$4; src=$5; user=$6;
  print ts "\t" rid "\t" host "\t" src "\t" user "\t" desc;
}' "$OUTDIR/edge-sequence-timeline.tsv" > "$OUTDIR/edge-sequence-ordered.tsv"

if [ -s "$OUTDIR/edge-sequence-ordered.tsv" ]; then
  column -t -s $'\t' "$OUTDIR/edge-sequence-ordered.tsv" || cat "$OUTDIR/edge-sequence-ordered.tsv"
else
  echo "[*] No ordered sequence to display"
fi

echo
echo "[*] Saved:"
echo "    $OUTDIR/edge-sequence-raw.jsonl"
echo "    $OUTDIR/edge-sequence-timeline.tsv"
echo "    $OUTDIR/edge-sequence-ordered.tsv"
