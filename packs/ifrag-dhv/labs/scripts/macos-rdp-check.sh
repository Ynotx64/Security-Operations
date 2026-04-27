#!/usr/bin/env bash
set -euo pipefail

echo "[*] Recent RDP-related process launches"
ps aux | egrep "Microsoft Remote Desktop|Windows App|xfreerdp|rdesktop|FreeRDP" || true

echo "[*] Recent network connections on 3389"
lsof -iTCP:3389 -nP || true
