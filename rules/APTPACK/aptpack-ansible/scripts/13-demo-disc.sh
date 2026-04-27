#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

SUBNET="${1:-192.168.1.0/24}"
HOSTS="${2:-192.168.1.1 192.168.1.46 192.168.1.106}"

echo "=== Tool checks ==="
command -v nmap || true
command -v nc || true
ip route || true

echo
echo "=== DISC correlation event: nmap scan ==="
nmap -sT "$SUBNET" || true

echo
echo "=== DISC anti-bypass event: targeted low-and-slow probes ==="
for h in $HOSTS; do
  echo "Probing $h"
  nc -zv "$h" 22 || true
  sleep 5
done

echo
echo "=== Dashboard search terms ==="
echo "$DISC_CORR_ID"
echo "$DISC_ANTI_ID"
echo "$SUBNET"
echo "$HOSTS"
