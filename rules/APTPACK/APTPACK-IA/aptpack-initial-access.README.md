# aptpack-initial-access.xml

## Purpose
Initial Access focused Linux-oriented rule set for early adversary activity including authentication abuse, tool transfer, sudo visibility, and command obfuscation patterns.

## Detection scope
This ruleset is intended to detect:
- authentication failure activity
- brute-force style repeated failures
- suspicious transfer tooling such as curl and wget
- shell and scripting obfuscation patterns
- early privilege use visibility via sudo

## ATT&CK scope
Primary ATT&CK coverage includes:
- T1110 Brute Force
- T1548 Abuse Elevation Control Mechanism
- T1105 Ingress Tool Transfer
- T1027.010 Obfuscated/Compressed Files and Information

## Telemetry dependency
This ruleset depends on:
- authentication-related groups such as `authentication_failed`
- command telemetry such as `audit_command`
- sudo/syslog event coverage

## Deployment notes
This file belongs in active Wazuh custom rules when Linux command and auth telemetry are available. If audit or auth grouping is absent, parts of the rule logic will not fire.

## SOC use
This ruleset supports early adversary detection and initial triage for authentication abuse, suspicious command execution, and low-complexity staging behavior.
