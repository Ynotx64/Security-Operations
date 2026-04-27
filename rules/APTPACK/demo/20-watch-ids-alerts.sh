#!/usr/bin/env bash
set -euo pipefail

echo "=== fast.log watch ==="
sudo tail -Fn0 /var/log/suricata/fast.log
