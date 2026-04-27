#!/usr/bin/env bash
set -euo pipefail

BASE="/opt/soc/detection-content"
REPORT_DIR="$BASE/manifests"
TS="$(date +%Y%m%d-%H%M%S)"
REPORT="$REPORT_DIR/validation-report-$TS.txt"

mkdir -p "$REPORT_DIR"

exec > >(tee -a "$REPORT") 2>&1

echo "============================================================"
echo "SOC Detection Content Validation Report"
echo "Timestamp: $TS"
echo "Base: $BASE"
echo "Host: $(hostname)"
echo "User: $(whoami)"
echo "============================================================"
echo

fail_count=0
warn_count=0

pass() { echo "[PASS] $*"; }
warn() { echo "[WARN] $*"; warn_count=$((warn_count+1)); }
fail() { echo "[FAIL] $*"; fail_count=$((fail_count+1)); }

section() {
  echo
  echo "------------------------------------------------------------"
  echo "$*"
  echo "------------------------------------------------------------"
}

section "1) Directory structure"

for d in \
  "$BASE" \
  "$BASE/packs/yaml/edge" \
  "$BASE/packs/xml/wazuh" \
  "$BASE/packs/suricata" \
  "$BASE/playbooks/edge" \
  "$BASE/scripts" \
  "$BASE/manifests"
do
  if [ -d "$d" ]; then
    pass "Directory exists: $d"
  else
    fail "Missing directory: $d"
  fi
done

echo
echo "File counts:"
echo "  YAML edge rules : $(find "$BASE/packs/yaml/edge" -maxdepth 1 -type f -name '*.yml' | wc -l)"
echo "  Playbooks       : $(find "$BASE/playbooks/edge" -maxdepth 1 -type f -name '*.yml' | wc -l)"
echo "  Wazuh XML       : $(find "$BASE/packs/xml/wazuh" -maxdepth 1 -type f -name '*.xml' | wc -l)"
echo "  Suricata rules  : $(find "$BASE/packs/suricata" -maxdepth 1 -type f -name '*.rules' | wc -l)"
echo "  Scripts         : $(find "$BASE/scripts" -maxdepth 1 -type f | wc -l)"

section "2) YAML syntax validation"

if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import yaml
PY
  then
    while IFS= read -r -d '' f; do
      if python3 - "$f" <<'PY'
import sys, yaml
p = sys.argv[1]
with open(p, 'r', encoding='utf-8') as fh:
    yaml.safe_load(fh)
PY
      then
        pass "Valid YAML: $f"
      else
        fail "Invalid YAML: $f"
      fi
    done < <(find "$BASE/packs/yaml/edge" "$BASE/playbooks/edge" "$BASE/manifests" -maxdepth 1 -type f -name '*.yml' -print0)
  else
    warn "PyYAML not installed; skipping YAML parser validation"
  fi
else
  fail "python3 not installed"
fi

section "3) Ansible playbook syntax"

if command -v ansible-playbook >/dev/null 2>&1; then
  while IFS= read -r -d '' f; do
    if ansible-playbook --syntax-check "$f" >/dev/null 2>&1; then
      pass "Ansible syntax OK: $f"
    else
      fail "Ansible syntax failed: $f"
      ansible-playbook --syntax-check "$f" || true
    fi
  done < <(find "$BASE/playbooks/edge" -maxdepth 1 -type f -name '*.yml' -print0)
else
  warn "ansible-playbook not installed; skipping playbook syntax checks"
fi

section "4) Wazuh XML well-formedness"

if command -v xmllint >/dev/null 2>&1; then
  while IFS= read -r -d '' f; do
    if xmllint --noout "$f" >/dev/null 2>&1; then
      pass "XML well-formed: $f"
    else
      fail "Malformed XML: $f"
      xmllint --noout "$f" || true
    fi
  done < <(find "$BASE/packs/xml/wazuh" -maxdepth 1 -type f -name '*.xml' -print0)
else
  warn "xmllint not installed; skipping XML well-formedness checks"
fi

section "5) Active Wazuh edge rule presence"

EDGE_IDS='EDGE-MGMT-008|EDGE-ADM-001|EDGE-CONFIG-002|EDGE-ACCT-003|EDGE-CTRL-004|EDGE-SVC-005|EDGE-EGRESS-006|EDGE-LOG-007'

if [ -d /var/ossec/etc ] || [ -d /var/ossec/ruleset ]; then
  EDGE_MATCHES="$(sudo grep -R -E "$EDGE_IDS" /var/ossec/etc /var/ossec/ruleset 2>/dev/null || true)"
  if [ -n "$EDGE_MATCHES" ]; then
    pass "EDGE rule identifiers found in active Wazuh paths"
    echo "$EDGE_MATCHES"
  else
    warn "No EDGE-* identifiers found in active Wazuh paths; edge YAML pack is still source content only"
  fi
else
  warn "/var/ossec paths not present; cannot check active Wazuh rule loading"
fi

section "6) Wazuh logtest availability"

WAZUH_LOGTEST=""
if [ -x /var/ossec/bin/wazuh-logtest ]; then
  WAZUH_LOGTEST="/var/ossec/bin/wazuh-logtest"
elif [ -x /var/ossec/bin/ossec-logtest ]; then
  WAZUH_LOGTEST="/var/ossec/bin/ossec-logtest"
fi

if [ -n "$WAZUH_LOGTEST" ]; then
  pass "Wazuh logtest available: $WAZUH_LOGTEST"
else
  warn "No wazuh-logtest/ossec-logtest binary found"
fi

section "7) Suricata test mode availability"

SURICATA_CFG=""
if command -v suricata >/dev/null 2>&1; then
  if [ -f /etc/suricata/suricata.yaml ]; then
    SURICATA_CFG="/etc/suricata/suricata.yaml"
  elif [ -f /usr/local/etc/suricata/suricata.yaml ]; then
    SURICATA_CFG="/usr/local/etc/suricata/suricata.yaml"
  fi

  if [ -n "$SURICATA_CFG" ]; then
    pass "Suricata binary and config found: $(command -v suricata), $SURICATA_CFG"
    TMP_RULE_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_RULE_DIR"' EXIT

    while IFS= read -r -d '' f; do
      bn="$(basename "$f")"
      if suricata -T -c "$SURICATA_CFG" -S "$f" -l "$TMP_RULE_DIR" >/dev/null 2>&1; then
        pass "Suricata rule test OK: $bn"
      else
        fail "Suricata rule test failed: $bn"
        suricata -T -c "$SURICATA_CFG" -S "$f" -l "$TMP_RULE_DIR" || true
      fi
    done < <(find "$BASE/packs/suricata" -maxdepth 1 -type f -name '*.rules' -print0)
  else
    warn "Suricata installed but config file not found; skipping rule test"
  fi
else
  warn "suricata not installed; skipping Suricata rule validation"
fi

section "8) Edge search script dry run"

EDGE_SCRIPT="$BASE/scripts/search-edge-sequence.sh"
if [ -x "$EDGE_SCRIPT" ]; then
  pass "Edge search script executable: $EDGE_SCRIPT"
  if [ -f /var/ossec/logs/alerts/alerts.json ]; then
    if sudo "$EDGE_SCRIPT" /var/ossec/logs/alerts/alerts.json /tmp/edge-sequence-validation >/dev/null 2>&1; then
      pass "Edge search script ran successfully against alerts.json"
      sudo ls -l /tmp/edge-sequence-validation || true
    else
      fail "Edge search script failed against alerts.json"
      sudo "$EDGE_SCRIPT" /var/ossec/logs/alerts/alerts.json /tmp/edge-sequence-validation || true
    fi
  else
    warn "/var/ossec/logs/alerts/alerts.json not found; skipping script execution"
  fi
else
  fail "Edge search script missing or not executable: $EDGE_SCRIPT"
fi

section "9) Summary"

echo "Warnings : $warn_count"
echo "Failures : $fail_count"

if [ "$fail_count" -eq 0 ]; then
  pass "Validation completed with no hard failures"
else
  fail "Validation completed with failures"
fi

echo
echo "Report saved to: $REPORT"
