# rules

## Purpose
This directory is the primary GitHub staging branch for custom detection content copied from active Wazuh development paths and related detection engineering trees.

## What is here
This branch currently contains:
- top-level custom Wazuh XML rules staged directly for GitHub
- nested APTPACK content for phase-based detection engineering
- nested detection-content material for edge, validation, manifests, scripts, tests, and platform content

## SOC relevance
This is the operational rule staging branch. It is where custom logic is reviewed before publication, cleanup, packaging, and deployment.

## Top-level staged rule files
- `aptpack-initial-access.xml`
- `aptpack_ia_react2shell_postex_rules.xml`
- `geoserver_rce_campaign_rules.xml`
- `local_rules.xml`
- `solarwinds_postcomp_credential_access_rules.xml`

## Expectations before GitHub
Every rule set should document:
- purpose
- attack phase
- ATT&CK mapping
- telemetry dependency
- deployment dependency
- validation notes
