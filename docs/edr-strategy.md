Detection & Telemetry Architecture (SIEM + IDS Integration)

1. Purpose of This Document

This document defines the detection and telemetry architecture for the SOC lab environment, including how logs, packet-derived metadata, alerts, and security-relevant host activity are collected, normalized, forwarded, and analyzed.

The goal of this design is not just to collect data, but to build a defensible detection pipeline capable of identifying:
	•	edge-device compromise
	•	suspicious DNS behavior
	•	low-and-slow beaconing
	•	identity and credential abuse
	•	privilege escalation
	•	east-west movement
	•	policy violations
	•	attacker persistence attempts

This document explains how the SOC telemetry stack is structured, why each component was selected, and how the data path supports detection engineering and incident response.

⸻

2. Detection Architecture Goals

The telemetry design was built to support five core objectives:

2.1 Centralized Visibility

All relevant data sources must feed a centralized analysis layer so defenders can correlate activity across hosts, network segments, and security controls.

2.2 Multi-Layer Detection

No single log source is sufficient. Detection must combine:
	•	host telemetry
	•	network telemetry
	•	authentication telemetry
	•	infrastructure device logs
	•	packet inspection outputs

2.3 Correlation Across Sources

A meaningful detection is often produced only after linking multiple weak signals, such as:
	•	DNS anomaly + NetFlow pattern + Suricata alert
	•	failed logins + privilege escalation + process creation
	•	router configuration change + outbound connection + identity anomaly

2.4 Segmented Telemetry Collection

Telemetry must reflect the segmented architecture of the lab so activity can be attributed to the correct trust zone.

2.5 Operational Usability

The stack must support real investigations, not just passive log collection. That means:
	•	searchable data
	•	structured fields
	•	alerting support
	•	repeatable detections
	•	timeline reconstruction

⸻

3. Core Telemetry Stack

The SOC lab telemetry architecture is built around the following major components:

3.1 Security Onion

Security Onion provides the network detection and network visibility layer.

Primary functions:
	•	Suricata IDS alerts
	•	Zeek network metadata
	•	packet capture support
	•	network session visibility
	•	protocol behavior analysis

3.2 Splunk

Splunk is used as the centralized SIEM and search layer for telemetry aggregation, enrichment, correlation, and investigation.

Primary functions:
	•	log ingestion
	•	indexing and search
	•	field extraction
	•	alerting and dashboards
	•	multi-source correlation

3.3 Wazuh

Wazuh provides host-based security monitoring, vulnerability visibility, and endpoint telemetry support.

Primary functions:
	•	agent-based telemetry
	•	file integrity monitoring
	•	vulnerability detection
	•	log collection
	•	host security monitoring

3.4 Universal Forwarders / Log Shippers

Where needed, lightweight log forwarders transport host and service data into the SIEM.

Primary functions:
	•	local file monitoring
	•	secure forwarding
	•	host attribution
	•	controlled data delivery to the central indexer

⸻

4. Telemetry Sources by Layer

The design intentionally maps telemetry sources to infrastructure layers.

4.1 Edge / Perimeter Layer

Telemetry sources:
	•	firewall logs
	•	router logs
	•	NAT and session records
	•	administrative changes
	•	VPN or remote access events

Detection value:
	•	external scanning
	•	inbound exploitation attempts
	•	outbound infrastructure-originated traffic
	•	router-as-relay behavior
	•	configuration drift

4.2 Management Network

Telemetry sources:
	•	admin authentication logs
	•	sudo logs
	•	SIEM access logs
	•	hypervisor access logs
	•	jump-host activity

Detection value:
	•	privileged access abuse
	•	off-hours admin activity
	•	lateral movement into control systems
	•	unauthorized management plane access

4.3 Enterprise Access Network

Telemetry sources:
	•	endpoint logs
	•	authentication events
	•	application logs
	•	system process activity
	•	DNS requests

Detection value:
	•	user compromise
	•	malware execution
	•	suspicious process creation
	•	abnormal outbound traffic
	•	credential abuse

4.4 IDS Monitoring Network

Telemetry sources:
	•	SPAN/mirror traffic
	•	Zeek logs
	•	Suricata alerts
	•	packet metadata
	•	PCAP artifacts

Detection value:
	•	protocol misuse
	•	beaconing
	•	command-and-control patterns
	•	lateral movement over network channels
	•	suspicious DNS behavior

⸻

5. Why This Architecture Was Chosen

5.1 Defense in Depth

The architecture was selected to avoid dependence on a single sensor type.

Example:
	•	host logs may show a suspicious process
	•	Zeek may show associated DNS behavior
	•	Suricata may show a signature hit
	•	firewall logs may show destination context

This layered design improves confidence and reduces blind spots.

5.2 Enterprise Realism

The selected tools and flows reflect real SOC practices:
	•	dedicated IDS layer
	•	centralized SIEM
	•	host-based monitoring
	•	segmented infrastructure
	•	controlled management access

5.3 Portability of Detection Logic

The design supports portable detection content using:
	•	Sigma-style logic
	•	Splunk SPL
	•	Wazuh rules
	•	Suricata signatures
	•	Zeek hunting queries

This makes the environment useful both for learning and for practical engineering.

⸻

6. High-Level Data Flow

The telemetry path follows a structured pipeline.

6.1 Network Telemetry Flow
	1.	traffic traverses segmented virtual networks
	2.	mirrored or monitored traffic reaches IDS sensors
	3.	Security Onion processes traffic
	4.	Suricata generates alerts
	5.	Zeek generates rich protocol metadata
	6.	network-derived telemetry is forwarded for centralized analysis

6.2 Host Telemetry Flow
	1.	endpoint or server generates local security-relevant logs
	2.	agent or forwarder collects logs
	3.	telemetry is normalized by sourcetype/source/host attribution
	4.	data is forwarded to Splunk and/or Wazuh
	5.	detections run against indexed data

6.3 Authentication / Identity Flow
	1.	user or service attempts authentication
	2.	authentication platform records result
	3.	logs are collected centrally
	4.	correlation searches evaluate patterns such as:
	•	brute force
	•	password spray
	•	success after repeated failures
	•	unusual privileged logins

⸻

7. Network Detection Components

7.1 Suricata

Suricata provides signature-based and protocol-aware network detection.

Used for:
	•	IDS alerting
	•	known bad signatures
	•	suspicious traffic patterns
	•	exploit attempts
	•	protocol anomalies

Key outputs:
	•	eve.json
	•	fast.log
	•	alert metadata

Operational role:
	•	immediate alert source
	•	useful for triage and packet pivoting

7.2 Zeek

Zeek provides high-value behavioral metadata rather than signature-only alerts.

Used for:
	•	connection summaries
	•	DNS logs
	•	HTTP logs
	•	SSL/TLS logs
	•	notices
	•	lateral movement reconstruction

Key outputs:
	•	conn.log
	•	dns.log
	•	notice.log
	•	protocol-specific logs

Operational role:
	•	behavioral hunting
	•	baseline comparison
	•	traffic reconstruction support

7.3 Packet Capture (PCAP)

PCAP is retained where feasible for deep validation.

Used for:
	•	packet-level review
	•	payload confirmation
	•	false-positive validation
	•	forensic reconstruction

Operational role:
	•	last-mile evidence source
	•	used after alerting or anomaly discovery

⸻

8. Host Detection Components

8.1 Wazuh Agents

Wazuh agents collect host telemetry and security state data.

Used for:
	•	file integrity monitoring
	•	process and system logs
	•	vulnerability inventory
	•	endpoint event monitoring

8.2 Native OS Logging

Examples include:
	•	Linux syslog / journald
	•	auth.log
	•	sudo logs
	•	service logs
	•	auditd where enabled

Detection value:
	•	login failures
	•	privilege escalation
	•	service modifications
	•	persistence artifacts

8.3 Splunk Universal Forwarder

Used where direct forwarding to Splunk is appropriate.

Responsibilities:
	•	monitor specific files
	•	assign host/source/sourcetype
	•	forward cooked data to the indexer
	•	preserve consistent telemetry identity

⸻

9. Normalization Strategy

Consistent telemetry depends on accurate classification.

Every input should preserve or assign:
	•	host
	•	source
	•	sourcetype
	•	index
	•	timestamp
	•	segment context when possible

9.1 Why This Matters

Bad source attribution breaks detection logic.

Examples:
	•	missing host field prevents host-based triage
	•	bad sourcetype prevents field extraction
	•	incorrect source path complicates troubleshooting
	•	timestamp errors destroy timelines

9.2 Practical Rule

Each telemetry source should have a clearly defined ingestion identity before production use.

⸻

10. Splunk Role in the Detection Pipeline

Splunk acts as the central operational analysis layer.

10.1 Core Functions
	•	search across all telemetry
	•	correlation by host, IP, user, process, and time
	•	dashboarding
	•	detection search execution
	•	analyst triage

10.2 Example Investigation Questions Splunk Must Answer
	•	What happened on this host in the last 30 minutes?
	•	Which DNS queries preceded this alert?
	•	Did this authentication event correlate with suspicious network activity?
	•	What sources are actively forwarding right now?
	•	Are management systems producing logs as expected?

10.3 Example Data Domains to Correlate
	•	Suricata alerts
	•	Zeek DNS and connection logs
	•	system authentication logs
	•	Wazuh alerts
	•	firewall telemetry
	•	hypervisor or admin logs

⸻

11. Wazuh Role in the Detection Pipeline

Wazuh strengthens host-level visibility and security-state awareness.

11.1 Primary Operational Use Cases
	•	endpoint monitoring
	•	policy checks
	•	vulnerability tracking
	•	file integrity alerts
	•	host security alerting

11.2 Complementary Role with Splunk

Wazuh is not a replacement for central correlation. It complements Splunk by adding:
	•	host integrity context
	•	endpoint security signals
	•	vulnerability intelligence
	•	agent-based observability

⸻

12. Detection Use Cases Supported by This Design

12.1 Edge Device Compromise

Correlate:
	•	router/firewall config drift
	•	outbound connections from infrastructure devices
	•	unusual DNS requests
	•	rare destination patterns

12.2 Password Spray / Credential Abuse

Correlate:
	•	repeated authentication failures
	•	distributed attempts across accounts
	•	successful login after failures
	•	privileged session start

12.3 Beaconing / Low-and-Slow C2

Correlate:
	•	regular connection intervals
	•	small repeated outbound sessions
	•	repeated DNS lookups
	•	Suricata / Zeek anomalies

12.4 Lateral Movement

Correlate:
	•	east-west connections
	•	uncommon internal access paths
	•	service creation or process launch
	•	privileged logon events

12.5 Management Plane Access Anomalies

Correlate:
	•	jump-host usage
	•	SIEM login logs
	•	hypervisor access
	•	off-baseline admin source IPs

⸻

13. First-Time Setup Process

This section documents the initial deployment flow for the telemetry architecture.

13.1 Step 1 — Build Segmented Network First

Before telemetry tools are deployed, the network must already provide:
	•	management segment
	•	enterprise segment
	•	IDS visibility path
	•	controlled routing and firewall policy

13.2 Step 2 — Deploy Security Onion in the Monitoring Layer

Tasks:
	•	install Security Onion
	•	attach interfaces appropriately
	•	verify mirrored or observed traffic path
	•	confirm Suricata and Zeek log generation

13.3 Step 3 — Deploy Splunk SIEM

Tasks:
	•	install Splunk Enterprise
	•	enable receiving on forwarding port (for example 9997)
	•	define indexes
	•	validate local search functionality
	•	confirm administrative access security

13.4 Step 4 — Install Wazuh Components

Tasks:
	•	deploy Wazuh manager/dashboard components
	•	enroll relevant agents
	•	confirm host telemetry arrival
	•	validate vulnerability and FIM functionality

13.5 Step 5 — Configure Log Forwarders

Tasks:
	•	install Splunk Universal Forwarder where required
	•	define monitored paths
	•	set correct sourcetypes
	•	configure outputs.conf to central indexer
	•	restart and validate connectivity

Example output target:

[tcpout]
defaultGroup = primary_indexer

[tcpout:primary_indexer]
server = 192.168.122.181:9997

13.6 Step 6 — Validate Forwarding

Validation must confirm:
	•	connection to indexer exists
	•	monitored files are watched
	•	events are searchable
	•	source/host/sourcetype fields are correct

13.7 Step 7 — Build Baseline Searches

Examples:
	•	active hosts in last 30 minutes
	•	active sources in last 30 minutes
	•	events by sourcetype
	•	tcpin connection visibility
	•	authentication failures
	•	DNS outliers

⸻

14. Example Validation Workflow

A practical first-use workflow should look like this:
	1.	create a known test log on a monitored host
	2.	write unique marker events into the file
	3.	verify UF or shipper is tailing the file
	4.	verify connection to Splunk indexer exists
	5.	search for the unique marker in Splunk
	6.	confirm host/source/sourcetype are correct
	7.	repeat for each major telemetry domain

This process prevents false confidence caused by partial connectivity with no searchable events.

⸻

15. Common Ingestion Failure Points

15.1 Forwarding Exists but Data Is Not Searchable

Possible causes:
	•	wrong sourcetype
	•	wrong source path
	•	monitored file not actually being written
	•	permissions issue on monitored file
	•	search syntax issue
	•	events indexed outside expected time range

15.2 Connection Seen in metrics.log but No Useful Events

This usually means transport is functioning but the actual monitored dataset is missing, misclassified, or not written correctly.

15.3 File Monitor Defined but File Does Not Exist

If a monitored file path is configured but the file or parent directory does not exist, no events will be collected from that source.

15.4 Wrong Host Context

If host attribution is inconsistent, correlation by system becomes unreliable.

⸻

16. Security Controls for Telemetry Infrastructure

The telemetry infrastructure itself must be protected.

16.1 Splunk Hardening
	•	restrict management access
	•	protect admin credentials
	•	use strong role separation
	•	limit who can modify inputs, indexes, and searches

16.2 Security Onion Hardening
	•	restrict console/admin access
	•	isolate sensor interfaces
	•	avoid unnecessary services

16.3 Forwarder Hardening
	•	only install where needed
	•	restrict local admin access
	•	monitor changes to inputs.conf / outputs.conf / props.conf

⸻

17. Why This Design Supports Real Defensive Operations

This telemetry model supports operational defense because it provides:
	•	visibility across trust zones
	•	both host and network context
	•	actionable search and triage capability
	•	a path for portable detection engineering
	•	validation mechanisms for ingestion health

It is not merely a logging setup. It is a structured detection architecture.

⸻

18. Recommended Next Documents

This document should be followed by:
	1.	Detection Content & Correlation Rules
	2.	Log Source Inventory & Data Mapping
	3.	Incident Triage Workflow
	4.	Threat Hunting Methodology
	5.	Splunk + Wazuh + Security Onion Validation Guide

⸻

19. Summary

The SOC lab detection architecture was built to provide layered visibility across network, host, identity, and control-plane activity. Security Onion supplies network telemetry and IDS visibility, Wazuh strengthens host monitoring, and Splunk serves as the central SIEM for correlation and investigation.

This design was chosen because it reflects real enterprise defensive architecture: segmented networks, controlled telemetry paths, multiple sensor types, and centralized analysis. With the correct field normalization, forwarding validation, and use-case-driven detection logic, this environment becomes a practical platform for defending against modern threats and developing repeatable SOC operations.
