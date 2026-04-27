# aptpack_ia_react2shell_postex_rules.xml

## Purpose
Post-exploitation Kubernetes and container-focused rule set designed to detect follow-on credential access, discovery, API abuse, staging, transfer, and cleanup behavior consistent with shell access after application compromise.

## Detection scope
This ruleset is intended to detect:
- Kubernetes service account token access
- namespace and identity discovery activity
- bearer-token or API access from shell tooling
- archive or base64 staging of sensitive material
- outbound curl/wget transfer behavior
- download + chmod + execute chains
- execute-and-delete temporary payload behavior

## ATT&CK scope
Primary ATT&CK coverage includes:
- T1528 Steal Application Access Token
- T1087 Account Discovery
- T1059 Command and Scripting Interpreter
- T1005 Data from Local System
- T1041 Exfiltration Over C2 Channel
- T1105 Ingress Tool Transfer
- T1070 Indicator Removal on Host

## Telemetry dependency
This ruleset currently depends on:
- osquery-linked event grouping
- command/process visibility with command-line content
- container or host process execution visibility

## Deployment notes
This ruleset should only be deployed where osquery process or equivalent command telemetry is present. It is specifically useful in containerized workloads and Kubernetes-adjacent environments.

## SOC use
This ruleset helps the SOC identify post-exploitation tradecraft after web compromise or shell foothold in containerized environments.
