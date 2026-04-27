# solarwinds_postcomp_credential_access_rules.xml

## Purpose
Credential Access ruleset modeled on post-compromise tradecraft associated with SolarWinds follow-on intrusion behavior, with emphasis on LSASS access, dumping patterns, and related DLL loading activity.

## Detection scope
This ruleset is intended to detect:
- suspicious LSASS dump command patterns
- high-confidence dump commands such as ProcDump / comsvcs MiniDump patterns
- suspicious credential-access-related DLL loads
- repeated credential dumping attempts through correlation logic

## ATT&CK scope
Primary ATT&CK coverage includes:
- T1003.001 LSASS Memory
- T1003 OS Credential Dumping
- T1218 Signed Binary Proxy Execution

## Telemetry dependency
This ruleset depends on Windows Sysmon-style telemetry such as:
- Event ID 1 process creation
- Event ID 7 image load
- command-line visibility
- image and DLL load field extraction

## Deployment notes
This ruleset should only be deployed where Sysmon field mapping is present and normalized into the expected Wazuh fields. It should be validated carefully because field-group mismatches can cause rule logic to be skipped.

## SOC use
This ruleset supports detection of high-value credential access behavior during post-compromise operations in Windows environments.
