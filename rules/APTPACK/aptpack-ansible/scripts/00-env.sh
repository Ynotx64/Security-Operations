#!/usr/bin/env bash
set -euo pipefail

export APTPACK_ROOT="/home/soc-admin/APTPACK"
export ANSIBLE_ROOT="/home/soc-admin/APTPACK/aptpack-ansible"
export IDS_HOST="ids-management"

# Change this to a real web target for IA / CA / STAGE HTTP tests.
# Example: export TARGET="192.168.1.46"
export TARGET="192.168.1.46"

export IA_CORR_ID="APTPACK-IA-CORR-001"
export IA_ANTI_ID="APTPACK-IA-ANTI-001"

export EXEC_CORR_ID="APTPACK-EXEC-CORR-001"
export EXEC_ANTI_ID="APTPACK-EXEC-ANTI-001"

export PE_CORR_ID="APTPACK-PE-CORR-001"
export PE_ANTI_ID="APTPACK-PE-ANTI-001"

export DISC_CORR_ID="APTPACK-DISC-CORR-001"
export DISC_ANTI_ID="APTPACK-DISC-ANTI-001"

export CA_CORR_ID="APTPACK-CA-CORR-001"
export CA_ANTI_ID="APTPACK-CA-ANTI-001"

export STAGE_CORR_ID="APTPACK-STAGE-CORR-001"
export STAGE_ANTI_ID="APTPACK-STAGE-ANTI-001"

export WAZUH_ALERTS="/var/ossec/logs/alerts/alerts.json"
export WAZUH_LOG="/var/ossec/logs/ossec.log"

echo "APTPACK demo env loaded"
echo "TARGET=$TARGET"
echo "IDS_HOST=$IDS_HOST"
