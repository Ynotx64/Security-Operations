# Honeypot Rule Refinement Checklist

## Global
- [ ] Replace broad string matches with decoder-backed field rules
- [ ] Normalize fields across all honeypots: source.ip, destination.port, honeypot.name, username, password, command, url, hash
- [ ] Add IOC enrichment for IPs, domains, URLs, and hashes
- [ ] Add MITRE ATT&CK mapping to every high-confidence rule
- [ ] Add threshold and suppression logic to reduce alert floods
- [ ] Add validation samples for each rule file
- [ ] Add dashboard pivots for source IP, honeypot, protocol, username, command, payload URL, and hash
- [ ] Tune rule severity to avoid disk and alert volume issues

## 000-honeypot-common.xml
- [ ] Replace generic service-name matching with decoded service fields
- [ ] Add per-protocol grouping and severity tiers
- [ ] Add first-seen source IP logic
- [ ] Add shared honeypot taxonomy tags

## 010-cowrie_rules.xml
- [ ] Split SSH vs Telnet detections
- [ ] Distinguish auth fail, auth success, session open, command exec, file download, and upload
- [ ] Add brute-force burst thresholds
- [ ] Add downloader patterns: wget, curl, tftp, busybox
- [ ] Add shell and miner command patterns
- [ ] Add default credential families
- [ ] Add success-after-fail correlation
- [ ] Add URL/hash IOC joins

## 020-dionaea_rules.xml
- [ ] Separate service targeting: SMB, FTP, MSSQL, HTTP, MQTT, TFTP
- [ ] Distinguish connection, exploit attempt, malware download
- [ ] Extract payload URLs and hashes
- [ ] Add worm/exploit family clustering
- [ ] Add repeated source and repeated payload correlation

## 030-heralding_rules.xml
- [ ] Split by protocol: POP3, IMAP, SMTP auth, SOCKS, PostgreSQL, VNC
- [ ] Add auth failure burst thresholds
- [ ] Add username spray and password reuse logic
- [ ] Add success-after-fail logic
- [ ] Correlate with Cowrie and Mailoney

## 040-honeytrap_rules.xml
- [ ] Split scan, probe, banner grab, and payload send
- [ ] Add burst/sweep thresholds
- [ ] Add multi-port recon correlation
- [ ] Correlate with Suricata and passive fingerprint sensors

## 050-mailoney_rules.xml
- [ ] Separate SMTP handshake, AUTH abuse, relay behavior, spam behavior
- [ ] Add MAIL FROM / RCPT TO volume thresholds
- [ ] Add suspicious HELO/EHLO patterns
- [ ] Correlate source IPs with Heralding and SentryPeer

## 060-elasticpot_rules.xml
- [ ] Separate enumeration APIs from write/destructive APIs
- [ ] Add request-path extraction
- [ ] Add destructive/index modification logic
- [ ] Add source reuse across web honeypots

## 070-redishoneypot_rules.xml
- [ ] Separate recon commands from takeover commands
- [ ] Add CONFIG SET / MODULE LOAD / SLAVEOF / REPLICAOF / EVAL high-severity logic
- [ ] Add persistence/abuse patterns
- [ ] Add source thresholds and downloader correlation

## 080-adbhoney_rules.xml
- [ ] Separate connect-only behavior from shell/push/pull/install actions
- [ ] Add APK staging and install logic
- [ ] Add repeated source thresholds

## 090-ciscoasa_rules.xml
- [ ] Separate VPN recon, auth attempts, and exploit-path access
- [ ] Add URI/path extraction
- [ ] Add auth spray thresholds
- [ ] Correlate with Suricata and other web-facing sensors

## 100-sentrypeer_rules.xml
- [ ] Split INVITE, REGISTER, OPTIONS, BYE, ACK
- [ ] Add SIP scan thresholds
- [ ] Add auth abuse logic
- [ ] Add geo/ASN enrichment for SIP abuse infrastructure

## 110-conpot_rules.xml
- [ ] Split IEC104, IPMI, Kamstrup, Guardian AST into separate protocol-aware rules
- [ ] Separate polling/recon from write/manipulation
- [ ] Add ICS ATT&CK mappings
- [ ] Add same-source multi-protocol OT correlation

## 120-dicompot_medpot_rules.xml
- [ ] Split DICOMPot and MedPot into separate files eventually
- [ ] Add medical transaction awareness
- [ ] Add recon vs manipulation separation
- [ ] Correlate with non-medical scans from same source

## 130-wordpot_honeyaml_h0neytr4p_rules.xml
- [ ] Split each service into separate rule files eventually
- [ ] Add WordPress plugin/theme/admin/xmlrpc detection
- [ ] Add YAML deserialization payload coverage
- [ ] Add HTTP method/path/user-agent extraction
- [ ] Add web exploit campaign clustering

## 140-print_and_ipp_rules.xml
- [ ] Split IPPHoney and MiniPrint
- [ ] Separate enumeration from job abuse
- [ ] Add repeated discovery thresholds

## 150-network_sensor_rules.xml
- [ ] Separate FATT and p0f by fingerprint type
- [ ] Add OS/network fingerprint extraction
- [ ] Correlate passive fingerprints with active attacks
- [ ] Add first-seen fingerprint pivots

## 160-suricata_rules.xml
- [ ] Replace generic string matches with parsed signature/category fields
- [ ] Add signature-category severity mapping
- [ ] Add joins to honeypot alerts by source IP, destination port, URL, and time
- [ ] Add IOC match promotion logic

## 170-support_services_rules.xml
- [ ] Keep these low-noise and operational
- [ ] Move non-attack support events to separate service-health content if needed

## 180-correlation_rules.xml
- [ ] Add field-aware correlation by source IP, username, password, URL, hash
- [ ] Add same-source hits across 3+ honeypots
- [ ] Add Cowrie success + downloader + IDS corroboration chain
- [ ] Add Heralding spray + Mailoney/CiscoASA auth chain
- [ ] Add Conpot + Suricata + IOC correlation
