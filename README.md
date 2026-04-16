# Security Operations

Enterprise detection and defense content library that provides structured defensive content for modern security operations. The goal is to build a repository that supports practical organizational security needs across detection engineering, defensive security operations, policy enforcement, system hardening, and validation.

The objective is to build a detection framework that:
	•	tracks realistic adversary tradecraft
	•	aligns detections to MITRE ATT&CK techniques
	•	supports Cyber Kill Chain phase coverage
	•	improves analyst triage through correlation
	•	raises confidence by linking multiple weak signals into stronger findings

This repository is intended to contain:

- **EDR measures**
- **Detection rules**
- **Policy enforcement content**
- **Query-based analytics**
- **Automated hardening actions**
- **Validation procedures**

Detection Content Categories

The detection content in this environment is grouped into six major categories.

3.1 Identity and Authentication Detections

Used to detect:
	•	password spray
	•	brute force
	•	unusual privileged logins
	•	failed-to-success authentication patterns
	•	lateral movement via reused credentials
	•	remote administration misuse

3.2 Host-Based Detections

Used to detect:
	•	suspicious process execution
	•	privilege escalation
	•	persistence mechanisms
	•	service creation or modification
	•	file integrity changes
	•	suspicious scripts or binaries

3.3 Network-Based Detections

Used to detect:
	•	known malicious traffic signatures
	•	suspicious DNS patterns
	•	beaconing behavior
	•	east-west lateral movement
	•	protocol misuse
	•	command-and-control characteristics

3.4 Infrastructure and Edge Detections

Used to detect:
	•	router or firewall config drift
	•	unexpected admin access to network devices
	•	outbound traffic from infrastructure devices
	•	changes to remote management posture
	•	abnormal control-plane access

3.5 Telemetry Integrity and Visibility Detections

Used to detect:
	•	missing log sources
	•	forwarder failure
	•	sensor silence
	•	sudden drop in expected telemetry
	•	log pipeline anomalies
  
3.6 Correlation Detections

Used to combine multiple lower-level detections into stronger findings.

3.7 Detections Relevant to APT-Style Intrusions

The environment is specifically designed to support defense against stealthy, persistent adversaries rather than only commodity attacks.

3.8 Traits of APT-Style Activity Reflected in Detection Design
	•	patient credential abuse
	•	low-volume traffic
	•	use of legitimate admin paths
	•	preference for infrastructure and edge access
	•	stealth persistence
	•	staged movement through trust zones
	•	long dwell time

3.9 Detection Themes for APT-Like Tradecraft
	•	unusual privileged login timing
	•	rare admin path usage
	•	edge-device anomalies
	•	long-lived low-bandwidth outbound traffic
	•	DNS-based C2 indicators
	•	account manipulation and access persistence
	•	movement toward management systems

  4. MITRE ATT&CK Mapping Strategy

The MITRE ATT&CK framework is used to classify detections by adversary behavior.

This is important because it allows the lab to measure:
	•	which parts of attacker tradecraft are covered
	•	where visibility gaps still exist
	•	how different detections support the same adversary objective

4.1 ATT&CK Usage in This Environment

The lab primarily maps detections to:
	•	Initial Access
	•	Execution
	•	Persistence
	•	Privilege Escalation
	•	Defense Evasion
	•	Credential Access
	•	Discovery
	•	Lateral Movement
	•	Collection
	•	Command and Control
	•	Exfiltration
	•	Impact

4.2 Example ATT&CK Techniques Relevant to the Lab

Examples of techniques the detection set is designed to address:
	•	T1110 – Brute Force
	•	T1078 – Valid Accounts
	•	T1021 – Remote Services
	•	T1059 – Command and Scripting Interpreter
	•	T1053 – Scheduled Task/Job
	•	T1543 – Create or Modify System Process
	•	T1562 – Impair Defenses
	•	T1036 – Masquerading
	•	T1046 – Network Service Scanning
	•	T1016 – System Network Configuration Discovery
	•	T1087 – Account Discovery
	•	T1071 – Application Layer Protocol
	•	T1071.004 – DNS
	•	T1095 – Non-Application Layer Protocol
	•	T1571 – Non-Standard Port
	•	T1568 – Dynamic Resolution

5. Cyber Kill Chain Mapping Strategy

The Cyber Kill Chain is used to understand the progression of an intrusion from early access through operational objective.

This model is useful because it helps analysts reason about where they are in the intrusion lifecycle.

5.1 Kill Chain Phases Used in This Document
	•	Reconnaissance
	•	Weaponization
	•	Delivery
	•	Exploitation
	•	Installation
	•	Command and Control
	•	Actions on Objectives

5.2 Why Kill Chain Mapping Matters

MITRE ATT&CK provides depth. The Cyber Kill Chain provides sequence.

Used together, they help answer both:
	•	what technique is occurring
	•	where in the intrusion lifecycle the adversary currently is


## Layout

- docs/
- packs/apt31-core/
- packs/ifrag-dhv/
- packs/aptpack-core/
- shared/
