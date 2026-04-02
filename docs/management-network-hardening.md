Management Network Hardening & Access Control

1. Purpose of This Document

This document defines the hardening strategy and access control model for the Management Network within the SOC lab environment.

The Management Network is the most critical trust zone. It contains:
	•	SIEM (Splunk, Wazuh)
	•	administrative systems
	•	hypervisor access
	•	orchestration and control tooling

Compromise of this network equals full environment compromise. Therefore, it must be hardened to a significantly higher standard than all other segments.

⸻

2. Security Objectives
	•	restrict access to authorized administrators only
	•	eliminate direct exposure to untrusted networks
	•	enforce strong authentication and identity controls
	•	minimize attack surface
	•	ensure full logging and accountability of all actions
	•	prevent lateral movement into management systems

⸻

3. Management Network Design Principles

3.1 Isolation First
	•	no direct access from enterprise network
	•	no direct internet browsing from management hosts
	•	all access must traverse controlled paths

3.2 Least Privilege Access
	•	users only access systems required for their role
	•	no shared admin accounts
	•	privilege escalation must be controlled and logged

3.3 Controlled Entry Points
	•	all access must go through a jump host (bastion host)
	•	no direct SSH/RDP to critical systems

⸻

4. Jump Host (Bastion) Architecture

4.1 Role of Jump Host

The jump host acts as the single controlled entry point into the management network.

Responsibilities:
	•	authenticate users
	•	enforce MFA
n- log all access
	•	restrict outbound connections

4.2 Placement
	•	located within the management network
	•	accessible only from a trusted source network (e.g., admin workstation VLAN)

4.3 Access Flow
	1.	admin connects to jump host
	2.	authentication + MFA enforced
	3.	from jump host → access internal systems

⸻

5. Authentication & Identity Controls

5.1 Multi-Factor Authentication (MFA)

Required for:
	•	jump host access
	•	SIEM platforms
	•	hypervisor access

5.2 Strong Credential Policy
	•	no password reuse
	•	minimum length: 14+ characters
	•	enforce account lockouts

5.3 Role-Based Access Control (RBAC)

Define roles such as:
	•	SOC Analyst
	•	Security Engineer
	•	Administrator

Each role:
	•	has defined permissions
	•	cannot exceed required access scope

⸻

6. System Hardening Standards

6.1 Base OS Hardening

Apply to all management systems:
	•	disable unused services
	•	remove unnecessary packages
	•	enforce secure boot where possible
	•	enable host-based firewall

6.2 SSH Hardening

# Disable root login
PermitRootLogin no

# Disable password authentication
PasswordAuthentication no

# Use key-based authentication only
PubkeyAuthentication yes

Restart SSH:

sudo systemctl restart ssh

6.3 Firewall on Management Hosts

Example using UFW:

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.122.0/24 to any port 22
sudo ufw enable


⸻

7. Network-Level Restrictions

7.1 Inbound Restrictions
	•	allow only from jump host or admin subnet
	•	block all enterprise-originated traffic

7.2 Outbound Restrictions
	•	restrict internet access
	•	allow only necessary update repositories

⸻

8. Logging & Monitoring

8.1 Required Logs
	•	authentication logs
	•	sudo/privilege escalation logs
	•	SSH session logs
	•	system changes

8.2 Centralized Logging

All logs forwarded to SIEM:
	•	Splunk
	•	Wazuh

8.3 Example Monitoring Use Cases
	•	unusual login times
	•	repeated failed authentication attempts
	•	privilege escalation anomalies
	•	new account creation

⸻

9. Endpoint Protection

Management systems must include:
	•	endpoint detection (EDR or auditd/Sysmon equivalent)
	•	file integrity monitoring
	•	process monitoring

⸻

10. Patch & Vulnerability Management

10.1 Regular Updates

sudo apt update && sudo apt upgrade -y

10.2 Vulnerability Monitoring
	•	integrate Wazuh vulnerability detection
	•	track critical CVEs
	•	prioritize high severity patches

⸻

11. Administrative Workflow Model

11.1 Secure Workflow
	1.	connect to jump host
	2.	authenticate with MFA
	3.	access target system
	4.	perform actions with least privilege
	5.	log all actions

11.2 Prohibited Actions
	•	direct login to management systems from enterprise network
	•	use of shared credentials
	•	disabling logging controls

⸻

12. Validation & Testing

12.1 Access Control Testing
	•	verify unauthorized systems cannot connect
	•	verify only jump host can access management systems

12.2 Authentication Testing
	•	test MFA enforcement
	•	test account lockout policies

12.3 Logging Validation
	•	confirm logs appear in SIEM
	•	verify alerting for suspicious behavior

⸻

13. Common Misconfigurations
	•	open SSH access to entire network
	•	lack of MFA
	•	excessive admin privileges
	•	missing logging
	•	internet browsing from management hosts

⸻

14. Why This Layer Matters

The management network is the control plane of the entire environment.

If compromised:
	•	attackers gain visibility into all systems
	•	detection capabilities are degraded
	•	full environment control is possible

Hardening this layer ensures:
	•	secure operations
	•	trustworthy monitoring
	•	resilient defensive posture

⸻

15. Summary

The management network is secured through strict isolation, controlled access via a jump host, strong identity enforcement, and hardened systems. Combined with centralized logging and continuous monitoring, this creates a secure control plane that supports reliable SOC operations and protects critical infrastructure components.
