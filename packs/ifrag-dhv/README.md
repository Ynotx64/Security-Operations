# ifrag-dhv

**Internet-Facing RDP Access Gateway — Detection, Hardening, and Validation**

This content pack provides enterprise-ready defensive content for detecting, hardening, and validating Remote Desktop exposure and abuse across Windows, Linux, and macOS-aligned environments.

## Scope

- **Windows**: Native RDP server exposure, brute-force activity, unusual remote logons, successful logons after failure bursts, firewall and service configuration drift, and post-logon abuse indicators.
- **Linux**: XRDP exposure, repeated authentication failures, suspicious successful remote desktop sessions, insecure service configuration, and supporting host hardening.
- **macOS**: RDP client execution, suspicious remote administration activity, and analyst visibility for environments where macOS endpoints are used to initiate remote sessions or where remote-access tooling may indicate abuse.

## Repository Structure

```text
ifrag-dhv/
├── ansible/
│   └── ubuntu-24.04/
├── elastic/
│   ├── detections/
│   └── dashboards/
├── labs/
│   ├── validation/
│   └── scripts/
├── splunk/
│   └── detections/
├── wazuh-sigma/
│   ├── sigma/
│   └── wazuh-rules/
└── yara/
```

## Objectives

- Detect RDP brute-force and password-spray activity
- Detect suspicious successful RDP logons
- Detect successful RDP logons after repeated failures
- Detect exposure of RDP services and insecure host configuration
- Restrict source IPs and reduce internet-facing attack surface
- Require Network Level Authentication where applicable
- Harden Ubuntu 24.04 systems that provide XRDP or support remote access infrastructure
- Validate controls and telemetry across platforms

## Severity

**High**

Public RDP and RDP-like remote access services remain high-risk because they enable credential attacks, remote interactive access, and follow-on lateral movement when poorly restricted.
