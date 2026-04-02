# Validation Matrix

## Windows / Identity
- Generate repeated failed logons against a privileged test account
- Validate successful privileged sign-in after failures
- Confirm Security event visibility and SIEM ingestion

## Cloud / M365 / Entra-style Telemetry
- Validate mailbox rule creation events
- Validate message access or search activity logs
- Validate admin or delegated access logs
- Validate source IP / ASN enrichment

## Linux
- Validate Ubuntu 24.04 hardening state on admin utility hosts
- Confirm fail2ban, auditd, rsyslog, and UFW baseline

## Web / Portal
- Validate successful access to a test engineering portal from a controlled source
- Validate logging of URI path, identity, and source IP context
