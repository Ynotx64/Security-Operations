Network Routing & Firewall Policy Documentation

1. Purpose of This Document

This document defines the routing architecture and firewall policy model for the segmented SOC lab environment. It builds on the secure network foundation and establishes how traffic is controlled, inspected, and restricted between network segments.

The goal is to move from simple segmentation to enforced trust boundaries, where all inter-network communication is explicitly defined, monitored, and controlled.

⸻

2. Core Objectives

The routing and firewall design was created to achieve the following:
	•	enforce strict separation between management, enterprise, and IDS networks
	•	control north-south and east-west traffic paths
	•	prevent unauthorized lateral movement
	•	ensure all critical traffic is observable and loggable
	•	provide deterministic and auditable communication flows
	•	support SOC detection, response, and containment workflows

⸻

3. Routing Architecture Overview

3.1 Routing Model Selection

A centralized routing model was selected, where all inter-network traffic passes through a controlled routing point.

This routing point can be implemented as:
	•	a virtual router VM
	•	a firewall appliance (preferred)
	•	a Linux host with routing and firewall controls

3.2 Why Centralized Routing

Centralized routing ensures:
	•	all traffic between segments is inspectable
	•	firewall policy enforcement is consistent
	•	logging and monitoring can be centralized
	•	no direct bypass between networks

A distributed or flat routing model would allow uncontrolled communication paths, reducing visibility and weakening security.

⸻

4. Network Segments and Routing Roles

4.1 Management Network
	•	subnet example: 192.168.122.0/24
	•	contains SIEM, admin systems, hypervisor access
	•	highest trust level
	•	tightly restricted inbound access

4.2 Enterprise Network
	•	subnet example: 192.168.20.0/24
	•	contains endpoints, servers, AD, applications
	•	moderate trust level

4.3 IDS Monitoring Network
	•	dedicated monitoring segment
	•	contains IDS/NSM systems (e.g., Suricata, Zeek)
	•	typically receives mirrored or controlled traffic
	•	not intended for general communication

⸻

5. Traffic Flow Design

5.1 North-South Traffic

Traffic entering or leaving the environment must pass through the edge firewall/router.

Controls include:
	•	ingress filtering
	•	egress filtering
	•	NAT (if required)
	•	logging of all external communications

5.2 East-West Traffic

Traffic between internal segments is tightly controlled.

Examples:
	•	enterprise → management: DENY by default
	•	management → enterprise: ALLOW (restricted to admin ports)
	•	enterprise → IDS: typically DENY
	•	IDS → management: ALLOW (log forwarding only)

5.3 Management Plane Traffic

Administrative traffic is restricted to:
	•	SSH
	•	HTTPS
	•	management APIs

Only allowed from trusted admin systems or jump hosts.

⸻

6. Firewall Policy Model

6.1 Default Policy

The firewall operates on a default deny model:
	•	deny all inbound traffic
	•	deny all inter-segment traffic unless explicitly allowed
	•	allow only required outbound traffic

6.2 Policy Structure

Firewall rules are structured by zone pairs:
	•	MGMT → ENTERPRISE
	•	ENTERPRISE → MGMT
	•	MGMT → IDS
	•	IDS → MGMT
	•	ENTERPRISE → INTERNET
	•	INTERNET → ENTERPRISE

Each rule is:
	•	explicitly defined
	•	logged
	•	minimal in scope

⸻

7. Example Firewall Rules

7.1 Management to Enterprise

Allow administrative access:
	•	SSH (22)
	•	RDP (3389)
	•	WinRM (5985/5986)

Restricted by:
	•	source IP (admin host only)
	•	destination (specific systems)

7.2 Enterprise to Management
	•	DENY ALL by default

Exceptions (if needed):
	•	log forwarding
	•	authentication services

7.3 Enterprise to Internet
	•	allow outbound HTTP/HTTPS
	•	restrict DNS to approved resolvers
	•	log all outbound connections

7.4 Internet to Enterprise
	•	deny all unsolicited inbound traffic
	•	allow only explicitly published services

7.5 IDS Communication
	•	allow IDS → SIEM (log forwarding)
	•	deny general inbound access to IDS systems

⸻

8. Implementation Using Linux (nftables)

If using a Linux-based router/firewall, nftables provides structured policy enforcement.

8.1 Enable IP Forwarding

sudo sysctl -w net.ipv4.ip_forward=1

Persist:

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

8.2 Basic nftables Configuration

sudo apt install nftables
sudo systemctl enable --now nftables

8.3 Example Policy

sudo nft add table inet filter

sudo nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
sudo nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
sudo nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

# Allow loopback
sudo nft add rule inet filter input iif lo accept

# Allow established traffic
sudo nft add rule inet filter input ct state established,related accept
sudo nft add rule inet filter forward ct state established,related accept

# Allow management SSH
sudo nft add rule inet filter input tcp dport 22 ip saddr 192.168.122.0/24 accept

# Allow MGMT -> ENTERPRISE admin access
sudo nft add rule inet filter forward ip saddr 192.168.122.0/24 ip daddr 192.168.20.0/24 tcp dport {22,3389,5985,5986} accept

# Block ENTERPRISE -> MGMT
sudo nft add rule inet filter forward ip saddr 192.168.20.0/24 ip daddr 192.168.122.0/24 drop


⸻

9. Logging and Visibility

All firewall actions should be logged where possible.

Key logging goals:
	•	denied connections
	•	administrative access attempts
	•	unusual east-west traffic
	•	outbound connections from sensitive systems

Example:

sudo nft add rule inet filter forward log prefix "FW_DROP: " drop

Logs should be forwarded to the SIEM for correlation.

⸻

10. Validation and Testing

10.1 Connectivity Testing
	•	verify allowed paths work
	•	verify denied paths fail

10.2 Security Testing
	•	attempt lateral movement
	•	test unauthorized access to management systems
	•	verify logs are generated and visible in SIEM

10.3 Monitoring Validation
	•	confirm IDS visibility of traffic
	•	confirm SIEM ingestion of firewall logs

⸻

11. Common Failure Conditions
	•	unintended routing between segments
	•	overly permissive firewall rules
	•	missing logging
	•	dual-homed systems bypassing controls
	•	lack of egress filtering

⸻

12. Why This Layer Is Critical

Segmentation without routing control is incomplete.

Routing and firewall policy provide:
	•	enforcement of trust boundaries
	•	visibility into traffic behavior
	•	control over attack paths
	•	ability to contain incidents

This layer transforms the network from a structured layout into a defensive control system.

⸻

13. Summary

The routing and firewall design uses centralized control, default deny policies, and explicit rule definitions to enforce secure communication between network segments. This ensures that all traffic is intentional, observable, and restricted based on role and necessity, enabling realistic SOC operations and effective defensive security testing.
