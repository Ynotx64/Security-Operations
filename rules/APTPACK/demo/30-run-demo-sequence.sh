#!/usr/bin/env bash
set -euo pipefail
source ~/APTPACK/demo/00-env.sh

echo "[1/6] Wazuh validation"
~/APTPACK/demo/01-validate-wazuh.sh || true

echo
echo "[2/6] EXEC demo"
~/APTPACK/demo/11-demo-exec.sh || true

echo
echo "[3/6] PE demo"
~/APTPACK/demo/12-demo-pe.sh || true

echo
echo "[4/6] IA demo"
~/APTPACK/demo/10-demo-ia.sh || true

echo
echo "[5/6] CA demo"
~/APTPACK/demo/14-demo-ca.sh || true

echo
echo "[6/6] STAGE demo"
~/APTPACK/demo/15-demo-stage.sh || true

echo
echo "Run DISC separately on a host with reachable scan targets:"
echo "~/APTPACK/demo/13-demo-disc.sh <subnet> \"<host1> <host2> <host3>\""
