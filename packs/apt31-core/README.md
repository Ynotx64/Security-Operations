# APT-31 Pack

**APT31 / Judgment Panda / Zirconium / Violet Typhoon — Detection, Hardening, and Validation**

This content pack provides enterprise-ready defensive content for detecting, hardening, and validating identity-led and targeted-access tradecraft associated with **APT31** public reporting.

## Scope

This pack is built around public reporting that ties APT31 to:

- targeted phishing and tracking-link activity
- credential and identity abuse
- privileged sign-in anomalies
- MSP and delegated-admin access anomalies
- access to telecom, engineering, and sensitive business portals from unusual identity context
- mailbox rule abuse and suspicious collection behavior

## Repository Structure

```text
APT-31/
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

- Detect targeted phishing-to-login chains
- Detect password spray against privileged or shared accounts
- Detect new privileged sign-ins from rare ASN, geo, or device context
- Detect MSP/admin access outside baseline
- Detect suspicious mailbox rule creation and collection behavior
- Detect unusual access to engineering or telecom-adjacent portals
- Harden Linux support systems that broker admin and identity workflows
- Validate detections and investigative pivots in lab conditions

## Severity

**High**

APT31 is best modeled as a credential-led espionage and targeted-access actor. The most useful detections focus on identity, admin access, portal abuse, collection behavior, and correlation of targeted email events to follow-on access.

## Recommended Deployment Order

1. Apply Ubuntu 24.04 hardening playbook to admin and utility hosts
2. Enable identity, email, endpoint, and server telemetry
3. Deploy Sigma rules and SIEM detections
4. Run lab validation scenarios for spray, privileged login, and mailbox-rule activity
5. Tune baselines for admin accounts, ASNs, and business portals
