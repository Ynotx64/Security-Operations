Secure Network Setup Documentation

1. Purpose of This Document

This document records the design and initial implementation of the secure network foundation for the lab environment. It explains why the network was built this way, what security goals drove the architecture, and the exact configuration sequence used to stand up the initial segmented network.

The intent is to document the project from the first principles of secure network design through the first operational deployment state, so the environment can be rebuilt, audited, expanded, or defended with a clear engineering baseline.

⸻

2. Project Objective

The secure network was developed to support a realistic defensive security operations environment rather than a flat lab network. The goal was to create a small but enterprise-aligned architecture that could:
	•	isolate administrative systems from user and sensor traffic
	•	reduce attack surface through segmentation
	•	support centralized logging, monitoring, and intrusion detection
	•	make east-west movement easier to detect
	•	support controlled management access to infrastructure and security tools
	•	provide a stable foundation for SOC workflows, telemetry collection, and incident response testing

A flat network would have been faster to deploy, but it would not have reflected how secure environments are actually designed or defended. Because the project is meant to support real security engineering practice, segmentation and role separation were treated as core requirements from the beginning.

⸻

3. Why This Architecture Was Chosen

3.1 Security rationale

The architecture was chosen around the principle that the network itself must enforce trust boundaries. In a secure environment, administrative systems, monitored workloads, and sensor infrastructure should not all reside in the same unrestricted segment.

The chosen model separates functions into dedicated network zones so that compromise in one area does not automatically provide unrestricted access to another.

This architecture supports several defensive outcomes:
	•	Management plane protection: Administrative access is isolated from general workload traffic.
	•	Containment: A compromised endpoint or server in one segment is less able to move laterally.
	•	Telemetry quality: IDS and logging systems can observe traffic more cleanly when traffic paths are intentionally designed.
	•	Operational clarity: Each segment has a defined purpose, which improves troubleshooting and policy design.
	•	Scalability: More hosts, sensors, or services can be added later without redesigning the entire environment.

3.2 Why not a flat lab

A flat lab would have introduced several problems:
	•	no meaningful separation between admin traffic and user traffic
	•	weak simulation of enterprise defensive architecture
	•	poor ability to test segmentation policies
	•	less realistic telemetry flows
	•	easier accidental exposure of management services

For a SOC-oriented project, a flat design would have produced convenience at the cost of realism and security.

3.3 Why a segmented virtual architecture

The lab is hosted on an Ubuntu hypervisor using virtualization. A segmented virtual architecture was selected because it allows:
	•	multiple isolated network domains on one physical host
	•	precise control of which virtual machines connect to which switches
	•	safe testing of routing, logging, IDS, and policy enforcement
	•	reproducible rebuilds with documented virtual networking

This approach provides enterprise-style design patterns without requiring a large hardware footprint.

⸻

4. Security Design Principles Used

The network design was guided by the following principles:

4.1 Least privilege

Systems should only communicate where required. Network access is based on role, not convenience.

4.2 Segmentation by function

Each network segment exists for a specific operational purpose, such as administration, monitored enterprise traffic, or IDS visibility.

4.3 Administrative isolation

Management services should not be directly reachable from user or general workload segments.

4.4 Telemetry-first design

The network should be structured so that security tools can collect logs, packet data, and network events reliably.

4.5 Realistic enterprise alignment

The environment should resemble the structure of a real enterprise security deployment closely enough to support professional defensive workflows.

⸻

5. Initial Network Architecture

The initial secure network was structured as a segmented virtual environment with multiple dedicated switch domains.

5.1 Core network zones

Management Network
Used for administration, SIEM access, hypervisor management, and control-plane functions.

Enterprise Network
Used for user systems, servers, directory services, and general workload traffic.

IDS Monitoring Network
Used for network security monitoring visibility, including traffic inspection and sensor connectivity where applicable.

5.2 Functional layers

The network was organized into a layered model:
	•	Edge / Internet-facing layer
	•	Management layer
	•	Enterprise access layer
	•	Security monitoring layer
	•	IDS visibility layer

This creates a clear traffic model and supports policy enforcement between layers.

5.3 Virtual switch layout

The design used separate virtual switches or bridges for each trust boundary.

Example logical mapping:
	•	vSwitch-MGMT for administrative and control traffic
	•	vSwitch-ENTERPRISENET for enterprise endpoints and servers
	•	vSwitch-IDS for IDS and monitoring visibility

This separation ensures that simply attaching a VM to the wrong segment becomes a visible design decision rather than an invisible failure in a flat network.

⸻

6. Why These Segments Were Chosen

6.1 Management network

This segment exists to protect the management plane.

It includes systems such as:
	•	admin workstation or jump host
	•	hypervisor management access
	•	SIEM management interfaces
	•	security tool dashboards
	•	orchestration or control functions

This network was separated because compromise of the management plane is one of the most dangerous failures in any environment. If attackers gain direct access to management systems, they can disable logging, alter configurations, create privileged accounts, or pivot into every connected segment.

6.2 Enterprise network

This segment represents operational hosts and standard workloads.

It includes systems such as:
	•	user endpoints
	•	application servers
	•	directory services
	•	general enterprise services

This network is intentionally distinct from the management network because enterprise systems generate the activity that must be monitored, but they should not share unrestricted access to the systems that administer them.

6.3 IDS monitoring network

This segment supports visibility and detection.

It exists so that network monitoring systems can receive mirrored, tapped, or designated traffic without being co-located with general production-style workloads. This reduces noise, improves role clarity, and helps maintain a defensible architecture for packet and event inspection.

⸻

7. Initial Build Sequence

The initial deployment was performed in a defined order so that the network foundation was secure before higher-level tools were added.

Phase 1: Prepare the hypervisor host
	1.	Install the Ubuntu hypervisor base system.
	2.	Update the system packages.
	3.	install virtualization tooling
	4.	confirm virtual networking support
	5.	identify physical interfaces and management access method

Phase 2: Define the virtual network structure
	1.	create the required Linux bridges or virtual switches
	2.	assign each bridge to a specific security role
	3.	verify bridge state and interface attachment
	4.	document IP plans and intended VM membership per segment

Phase 3: Establish the management segment first
	1.	configure the management bridge
	2.	assign the management IP space
	3.	ensure administrative access works only through the intended path
	4.	validate that the hypervisor and management workstation can communicate

Phase 4: Stand up enterprise and IDS segments
	1.	create enterprise and IDS bridges
	2.	attach VMs only to the segments required for their role
	3.	avoid dual-homing except where explicitly necessary for sensors or controlled routing functions
	4.	validate layer-3 expectations before deploying security tools

Phase 5: Deploy security monitoring components
	1.	attach SIEM and monitoring systems to the management network
	2.	attach IDS systems to the IDS visibility network and any required monitored interfaces
	3.	confirm logging and traffic paths
	4.	begin validating telemetry ingestion

⸻

8. Exact Initial Configuration Steps

The exact commands depend on whether the environment used Linux bridges, libvirt virtual networks, Open vSwitch, or a combination. The documented baseline below assumes an Ubuntu hypervisor using Linux bridge networking with KVM/libvirt.

8.1 Identify interfaces

First, identify the physical NICs and current addressing.

ip addr
ip route
nmcli device status

Record:
	•	physical uplink interface
	•	current management IP
	•	default gateway
	•	DNS configuration

8.2 Install virtualization and bridge tooling

sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

Confirm services:

sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd

8.3 Create Linux bridges

Example bridge creation:

sudo ip link add name br-mgmt type bridge
sudo ip link add name br-enterprise type bridge
sudo ip link add name br-ids type bridge

sudo ip link set br-mgmt up
sudo ip link set br-enterprise up
sudo ip link set br-ids up

Verify:

ip link show type bridge
bridge link

8.4 Persist bridge configuration with Netplan

Example conceptual Netplan structure:

network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
  bridges:
    br-mgmt:
      interfaces: [eno1]
      dhcp4: no
      addresses: [192.168.122.10/24]
      routes:
        - to: default
          via: 192.168.122.1
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
    br-enterprise:
      interfaces: []
      dhcp4: no
    br-ids:
      interfaces: []
      dhcp4: no

Apply carefully from console access if remote:

sudo netplan try
sudo netplan apply

Why this was done
	•	br-mgmt carries the host administrative path.
	•	br-enterprise provides isolated connectivity for workload VMs.
	•	br-ids provides a dedicated security visibility network.

Only the management bridge receives the primary administrative IP in the initial build, because the host itself should not sit directly inside every segment.

8.5 Validate bridge state

ip addr show br-mgmt
ip addr show br-enterprise
ip addr show br-ids
bridge link
brctl show

Validate:
	•	management bridge has expected address
	•	enterprise and IDS bridges are up
	•	no unintended IP assignments exist on non-management bridges

8.6 Create VM network attachments

When provisioning VMs, attach NICs according to role.

Example role mapping
	•	Admin/SIEM VM → br-mgmt
	•	Directory or server VM → br-enterprise
	•	User workstation VM → br-enterprise
	•	IDS sensor VM → br-ids and, if required, an additional monitored interface depending on design

This ensures role-based connectivity instead of broad shared access.

8.7 Configure IP addressing inside guest systems

Assign static or controlled DHCP addressing per segment.

Example model:
	•	Management network: 192.168.122.0/24
	•	Enterprise network: 192.168.20.0/24
	•	IDS network: dedicated monitoring range

Each guest should only have routes required for its role. Avoid unnecessary default routes on sensor-only interfaces.

8.8 Validate segmentation

From each system, test only intended connectivity.

Examples:

ping <management-ip>
ping <enterprise-host>
ss -tulpen
ip route
traceroute <target>

Questions to validate:
	•	can enterprise hosts reach management interfaces directly when they should not?
	•	can IDS systems observe required traffic without exposing management services?
	•	do administrative systems have controlled reachability to workloads?

⸻

9. Initial Security Controls Applied

The secure network was not only segmented structurally; it was also intended to support baseline control enforcement.

9.1 Restricted management access

Administrative access should originate only from designated admin systems or jump paths.

9.2 No direct trust between enterprise and management segments

Communication between these networks should be intentional and minimal.

9.3 Monitoring-first placement

Security tools should be placed where they can collect telemetry without becoming casually exposed to all traffic.

9.4 Clear role assignment per VM

Every VM should have a justified network placement. No system should be multi-homed without a specific operational reason.

⸻

10. Initial Validation Checklist

After first deployment, the following validation steps were used or should be used:

Network foundation
	•	bridges created successfully
	•	management access preserved after bridge conversion
	•	enterprise and IDS bridges up and available
	•	VM interfaces mapped to correct bridges

Connectivity validation
	•	admin systems reachable on management segment
	•	enterprise systems communicate within expected boundaries
	•	IDS or monitoring systems attached correctly
	•	no accidental unrestricted routing between segments

Security validation
	•	management plane not exposed to enterprise users by default
	•	logging and monitoring paths defined
	•	topology documented for rebuild and troubleshooting

⸻

11. Why This Setup Matters for the Rest of the Project

This initial secure network setup is the foundation for everything that follows in the project.

Without this design:
	•	SIEM visibility would be less meaningful
	•	IDS placement would be weaker
	•	lateral movement testing would be unrealistic
	•	segmentation policy development would be impossible to validate properly
	•	administrative security would be too weak for a serious SOC lab

This network is therefore not just a transport layer. It is the first enforcement layer of the entire defensive architecture.

⸻

12. Recommended Next Documentation Section

After this section, the next logical writeup should be:
	1.	Hypervisor and virtualization platform setup
	2.	Management network hardening
	3.	SIEM and IDS deployment sequence
	4.	Initial routing and firewall policy model
	5.	Telemetry onboarding and validation

⸻

13. Short Summary

The secure network was designed as a segmented, enterprise-style virtual architecture to support realistic defensive operations. The architecture was chosen to protect the management plane, isolate workloads, improve telemetry quality, and enable controlled security monitoring. The initial setup began with the hypervisor, then bridge creation, then management network establishment, followed by enterprise and IDS segmentation, VM attachment by role, and validation of trust boundaries.

This approach created a security-focused base environment rather than a convenience-based flat lab, which is why it is the correct foundation for the rest of the project.
