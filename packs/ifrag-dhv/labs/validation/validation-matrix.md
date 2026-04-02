# Validation Matrix

## Windows
- Generate multiple failed RDP logons to trigger brute-force detections
- Validate Event ID 4625 with Logon Type 10
- Validate successful RDP logon Event ID 4624 after a failure burst
- Validate registry or policy changes related to RDP hardening
- Confirm NLA and firewall restrictions are enforced

## Linux
- Validate XRDP is disabled when not required
- If XRDP is enabled, generate repeated failed logons
- Confirm `/var/log/xrdp-sesman.log` ingestion
- Confirm UFW allows 3389 only from approved source ranges
- Confirm fail2ban blocks repeated offenders

## macOS
- Validate process execution telemetry for Microsoft Remote Desktop or FreeRDP clients
- Validate alert visibility for unusual or unauthorized RDP client usage
- Confirm endpoint telemetry captures process and destination metadata
