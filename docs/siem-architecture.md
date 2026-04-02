# NetStack — Enterprise Network Topology and SOC Environment

## 1. Overview

This document defines the enterprise-style network topology and Security Operations Center (SOC) environment used in the lab. The architecture is designed to simulate a segmented defensive security environment that supports monitoring, analysis, automation, and response.

The lab is hosted on an Ubuntu-based KVM hypervisor and uses virtual switching plus an internal firewall to separate management, enterprise workload, and IDS monitoring functions into distinct security zones.

The goal of the design is to mirror how a small enterprise SOC or security engineering environment would separate infrastructure, user traffic, and monitoring visibility while still remaining practical for a single-host lab deployment.

This architecture emphasizes:

* network segmentation
* centralized security monitoring
* controlled inter-network routing
* security telemetry collection
* automated response capability
* remote administrative access through a protected path

---

## 2. Topology Summary

### Architecture Type

**Hierarchical star topology with internal segmentation firewalling**

### Design Characteristics

* all major lab networks converge through a central policy enforcement point
* the firewall acts as the internal routing and control boundary
* virtual switches represent enterprise network access domains
* management, enterprise, and IDS functions are separated into distinct subnets
* remote analyst access is abstracted through VPN-assisted administrative connectivity

### Security Value

This design improves defensive control by:

* reducing unnecessary east-west exposure
* separating management traffic from monitored traffic
* centralizing routing and filtering decisions
* preserving a dedicated monitoring enclave
* supporting alert-driven response workflows

---

## 3. Logical Architecture

```text
Internet
   |
ISP / Home Router
192.168.1.1
   |
Ubuntu Host / KVM Hypervisor
192.168.1.46
Tailscale VPN: 100.x.x.x
   |
vSwitch-MGMT
192.168.122.0/24
   |
+-- Wazuh Server          192.168.122.10
+-- Splunk Server         192.168.122.20
+-- Ansible Control Node  192.168.122.40
+-- OPNsense WAN          192.168.122.254
   |
OPNsense Firewall VM
   |
+-------------------------+-------------------------+
|                                                   |
vSwitch-ENTERPRISENET                               vSwitch-IDS
192.168.50.0/24                                     192.168.70.0/24
|                                                   |
Windows / Linux Clients                             Security Onion
Internal Servers                                    192.168.70.1 or 192.168.70.10
```

### Core Functional Flow

* internet access enters through the upstream home router
* the Ubuntu host runs the virtual infrastructure and switch fabric
* the management segment hosts core SOC tooling and the firewall WAN side
* OPNsense routes and filters traffic between internal lab zones
* EnterpriseNet simulates enterprise users and workloads
* the IDS segment supports network security monitoring and traffic inspection

---

## 4. Network Segments

### 4.1 Edge / Upstream Network

**Network:** 192.168.1.0/24
**Gateway:** 192.168.1.1
**Primary Components:** ISP/Home Router, Ubuntu Host, remote access path

#### Purpose

Provides upstream internet connectivity and the outer network boundary for the lab.

#### Functions

* internet egress and ingress path
* upstream NAT boundary
* default gateway for the hypervisor host on the home LAN
* external path for remote analyst connectivity

#### Enterprise Equivalent

* WAN edge
* ISP handoff
* branch edge router
* internet perimeter connection

#### Example Real-World Hardware

* Cisco ISR 4331
* Cisco ASR 1001-X
* Juniper SRX300
* Fortinet FortiGate branch edge platform

---

### 4.2 Management Network

**Virtual Switch:** `vSwitch-MGMT`
**Subnet:** 192.168.122.0/24

#### Purpose

Dedicated management and SOC services network that hosts core security tooling, orchestration components, and the firewall’s upstream internal interface.

#### Functions

* security operations platform hosting
* centralized log and event intake
* administrative access path to core SOC systems
* automation and remediation orchestration
* controlled access to network security controls

#### Enterprise Role Mapping

This segment most closely represents a:

* management VLAN
* infrastructure administration network
* SOC services access layer

#### Enterprise Switch Role

**Management access switch** or **management services access layer**

#### Example Real-World Hardware

* Cisco Catalyst 9200
* Cisco Catalyst 9300
* Juniper EX4300
* Arista 7050X

---

### 4.3 Enterprise Workload Network

**Virtual Switch:** `vSwitch-ENTERPRISENET`
**Subnet:** 192.168.50.0/24

#### Purpose

Represents the corporate internal user and workload environment.

#### Functions

* simulate employee endpoint traffic
* simulate internal server communications
* generate application and authentication telemetry
* provide realistic traffic for monitoring and detection workflows

#### Enterprise Role Mapping

This segment represents a:

* user access VLAN
* enterprise endpoint network
* internal workload or access layer segment

#### Enterprise Switch Role

**Access layer switch**

#### Example Real-World Hardware

* Cisco Catalyst 9300
* Cisco Catalyst 9200
* Juniper EX3400
* Arista 720XP

---

### 4.4 IDS Monitoring Network

**Virtual Switch:** `vSwitch-IDS`
**Subnet:** 192.168.70.0/24

#### Purpose

Dedicated monitoring enclave for network security monitoring tools and inspection sensors.

#### Functions

* packet analysis
* IDS alert generation
* network telemetry processing
* traffic inspection for suspicious activity

#### Enterprise Role Mapping

This segment represents a:

* monitoring enclave
* IDS sensor network
* SPAN/TAP aggregation zone

#### Enterprise Switch Role

**Monitoring aggregation switch** or **SPAN/TAP collector switch**

#### Example Real-World Hardware

* Cisco Nexus 93180YC
* Arista 7280R
* Gigamon packet broker
* Ixia visibility platform

---

## 5. Core Infrastructure Components

### 5.1 ISP / Home Router

**Address:** 192.168.1.1

#### Role

Upstream gateway providing external connectivity for the lab host.

#### Responsibilities

* default route to the internet
* upstream NAT/PAT
* home LAN routing
* base connectivity for the hypervisor and remote analyst path

#### Enterprise Equivalent

* WAN edge router
* branch perimeter gateway
* internet handoff router

---

### 5.2 Ubuntu Host (KVM Hypervisor)

**Address:** 192.168.1.46
**VPN Address:** 100.x.x.x via Tailscale

#### Role

Primary compute node and virtual infrastructure host for the entire lab.

#### Responsibilities

* host all virtual machines
* provide virtual switch / bridge infrastructure
* support segmented virtual network design
* provide local administration and hypervisor control
* host remote administrative access path through Tailscale

#### Enterprise Equivalent

* VMware ESXi host
* Proxmox virtualization node
* Cisco UCS compute node
* Dell PowerEdge virtualization server

#### Administrative Interpretation

This host is not just a laptop or workstation. In enterprise terms, it functions as:

* a virtualization platform
* a compact network services host
* the physical substrate for the SOC environment

---

### 5.3 Remote Analyst Laptop

#### Role

Administrative endpoint used by the analyst to access the SOC lab remotely.

#### Responsibilities

* initiate remote management sessions
* access dashboards and security tooling
* investigate alerts
* trigger or supervise remediation workflows

#### Enterprise Equivalent

* SOC analyst workstation
* secured jump host client
* remote administrative endpoint

#### Security Consideration

Remote access should be limited to:

* VPN-protected paths
* approved administrative ports
* authenticated analyst systems

---

## 6. SOC Platform Components on the Management Network

### 6.1 Wazuh Server

**Address:** 192.168.122.10

#### Role

Primary host-based security monitoring and alerting platform.

#### Core Functions

* endpoint visibility
* log collection
* file integrity monitoring
* vulnerability awareness
* security event detection

#### Enterprise Equivalent

* Elastic Security
* Microsoft Defender XDR
* CrowdStrike Falcon with centralized telemetry platform

#### Lab Function

Wazuh receives host-level security events and provides a foundational detection capability across the managed environment.

---

### 6.2 Splunk Server

**Address:** 192.168.122.20

#### Role

Centralized log analytics and security data analysis platform.

#### Core Functions

* log indexing
* search and correlation
* SOC dashboards
* threat hunting workflows
* event investigation support

#### Enterprise Equivalent

* Splunk Enterprise Security
* IBM QRadar
* Microsoft Sentinel

#### Lab Function

Splunk provides broad log visibility and analytical context beyond single-host detections.

---

### 6.3 Ansible Control Node

**Address:** 192.168.122.40

#### Role

Administrative automation and response execution platform.

#### Core Functions

* automate firewall changes
* automate host configuration changes
* execute repeatable remediation playbooks
* standardize operational response actions

#### Enterprise Equivalent

* Red Hat Ansible Automation Platform
* infrastructure automation controller

#### Lab Function

Ansible provides the execution layer for repeatable incident response and configuration enforcement.

---

### 6.4 Optional SOAR Component

**Example Address:** 192.168.122.30

#### Role

Security orchestration and automated workflow engine.

#### Core Functions

* connect alerts to actions
* trigger analyst notifications
* invoke response playbooks
* coordinate between SIEM, IDS, and infrastructure controls

#### Enterprise Equivalent

* Cortex XSOAR
* Splunk SOAR
* Tines
* n8n for lab-scale workflow orchestration

#### Lab Function

Where deployed, this component acts as the decision and orchestration layer between detection and automated response.

---

## 7. Firewall and Internal Segmentation Layer

### OPNsense Firewall VM

**Management-side / WAN-side Address:** 192.168.122.254

#### Role

Primary internal routing and policy enforcement point for lab segmentation.

#### Core Functions

* route traffic between lab zones
* enforce firewall policy between segments
* log allowed and denied traffic
* act as the primary inter-network control boundary

#### Enterprise Equivalent

* Palo Alto PA-3220
* Fortinet FortiGate 200F
* Cisco Firepower 2110
* Check Point 6200

#### Architectural Importance

This is the central control point of the environment. In enterprise terms, it behaves like an:

* internal segmentation firewall
* distribution-layer policy enforcement device
* east-west traffic control boundary

#### Security Value

Without this layer, the environment would behave more like a flat lab network. With it, the design more closely mirrors enterprise zone-based security.

---

## 8. IDS and Monitoring Platform

### Security Onion

**Address:** diagram may reflect 192.168.70.1 or 192.168.70.10 depending on deployment

#### Role

Dedicated network security monitoring platform on the IDS segment.

#### Core Functions

* Suricata intrusion detection
* Zeek network analysis
* packet capture
* traffic-based alerting
* network telemetry enrichment

#### Enterprise Equivalent

* dedicated NSM appliance
* enterprise IDS sensor stack
* network detection and response collector

#### Lab Function

Security Onion provides network-layer visibility that complements host-based and log-based security monitoring.

---

## 9. Topology Roles Mapped to Enterprise Networking

| Lab Component         | Enterprise Function                               | Enterprise Role                      |
| --------------------- | ------------------------------------------------- | ------------------------------------ |
| Home Router / ISP     | internet edge connectivity                        | WAN edge router                      |
| Ubuntu KVM Host       | virtualization and virtual switching platform     | compute / virtualization node        |
| vSwitch-MGMT          | infrastructure and SOC services network           | management access switch             |
| OPNsense Firewall VM  | segmented internal routing and policy enforcement | internal segmentation firewall       |
| vSwitch-ENTERPRISENET | endpoint and workload access network              | access layer switch                  |
| vSwitch-IDS           | monitoring aggregation and sensor zone            | monitoring / SPAN aggregation switch |
| Wazuh                 | host-based security monitoring                    | XDR / HIDS platform                  |
| Splunk                | centralized analytics and correlation             | SIEM / analytics platform            |
| Ansible               | automated administrative response                 | automation controller                |
| Security Onion        | network-based monitoring                          | IDS / NSM sensor stack               |

---

## 10. Data Flow and Security Telemetry Flow

### Operational Traffic Flow

1. enterprise clients and servers generate normal user and application traffic
2. traffic is routed through the internal firewall boundary where policy is enforced
3. monitoring tooling observes relevant network or host events
4. logs and alerts are forwarded to management-zone analysis platforms
5. analysts investigate results and automate response where needed

### Security Telemetry Flow

```text
Enterprise Hosts / Services
   |
Operational Activity and Network Traffic
   |
Security Onion / Wazuh
   |
Security Events and Alerts
   |
Splunk Correlation and Analysis
   |
Analyst Review or Automated Logic
   |
Ansible / SOAR Response Actions
   |
Firewall or Host-Level Enforcement
```

### Example Detection-to-Response Workflow

* a suspicious event is detected on an endpoint or in network traffic
* Wazuh or Security Onion generates an alert
* Splunk ingests and correlates the event with additional telemetry
* the analyst reviews the finding or an automated workflow is triggered
* Ansible or a SOAR component executes containment or configuration changes
* OPNsense or the affected host enforces the remediation action

---

## 11. SOC Operational Workflow

### Detection

Security Onion and Wazuh identify suspicious host or network activity.

### Analysis

Splunk aggregates telemetry and provides analyst-friendly search, dashboards, and event context.

### Triage

The analyst determines whether the event is benign, suspicious, or actionable.

### Automation

Workflow logic or orchestration tooling maps alert types to predefined response actions.

### Response

Ansible and firewall controls execute containment, blocking, or remediation changes.

### Validation

The analyst confirms that the response succeeded and that telemetry reflects the new state.

---

## 12. Security and Architectural Benefits

### Segmentation

Separate networks reduce unnecessary trust and make lateral movement more difficult.

### Visibility

Host-based and network-based monitoring provide layered detection coverage.

### Centralized Logging

Critical telemetry is concentrated in dedicated SOC tooling for investigation and correlation.

### Policy Enforcement

Inter-network communication is routed through a central enforcement point.

### Automation

The environment can support faster and more repeatable defensive actions.

### Modularity

Additional sensors, servers, subnets, or orchestration functions can be added without redesigning the entire lab.

---

## 13. Enterprise Relevance

Although this environment is hosted on a single physical system, the design principles are enterprise-relevant.

The architecture resembles:

* a compact enterprise SOC lab
* a cyber range or security training environment
* a managed security services staging environment
* an internal incident response or detection engineering lab

What makes it enterprise-style is not the hardware scale. It is the presence of:

* segmented zones
* clear device roles
* centralized monitoring
* defined routing and control boundaries
* automation-ready response paths

---

## 14. Administrative Guidance

When documenting, operating, or demonstrating this environment, describe it in terms of:

* zones and trust boundaries
* control points
* data flows
* security telemetry paths
* enforcement points
* analyst access paths

The most accurate way to explain it is:

**This is a virtualized, segmented SOC architecture implemented on a compact KVM platform, using enterprise-style network roles and internal firewalling to simulate real-world defensive operations.**

---

## 15. Conclusion

NetStack represents a realistic defensive security architecture built from modular enterprise concepts:

* an upstream edge connection
* a virtualization host acting as the infrastructure substrate
* a dedicated management network for SOC services
* a firewall acting as the internal control boundary
* an enterprise workload network for simulated user and server activity
* an IDS monitoring network for network security visibility
* centralized logging, analysis, and response tooling

This makes the environment suitable for:

* SOC workflow demonstrations
* detection engineering practice
* incident response testing
* security administration training
* enterprise-style architecture explanation

As the lab evolves, new systems can be added into the same model by assigning them to the appropriate zone and maintaining the same design discipline around segmentation, monitoring, and policy enforcement.
