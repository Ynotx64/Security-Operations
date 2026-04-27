#!/usr/bin/env bash
set -euo pipefail
sudo tail -Fn0 /var/ossec/logs/alerts/alerts.json | grep --line-buffered -E 'APTPACK|aptpack_'
