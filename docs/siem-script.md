# Script 3 — NetStack Enterprise Topology and SOC Environment

## Format

**Strict Instructor Cue Sheet with Timestamps**

## Video Title

**Enterprise Network Topology and SOC Environment: NetStack Architecture Walkthrough**

## Total Target Runtime

**15:00**

## Delivery Standard

* speak clearly and at a measured pace
* pause at each major visual section of the topology
* do not improvise beyond brief natural transitions
* keep cursor movement deliberate and minimal
* leave each highlighted device or segment visible long enough to be read

## Recording Assumptions

* the topology diagram is open on screen before recording begins
* the presenter can zoom into areas of the diagram as needed
* the environment being described matches the current NetStack documentation
* the presenter will explain this as a defensive SOC architecture, not a penetration testing lab

---

# 1. Cue Sheet Overview

| Time        | Segment                         | Objective                                                      |
| ----------- | ------------------------------- | -------------------------------------------------------------- |
| 00:00–00:55 | Opening                         | establish scope and explain what NetStack represents           |
| 00:55–02:10 | Topology overview               | explain the overall architecture and hierarchy                 |
| 02:10–03:20 | Edge and upstream layer         | explain internet path, router, and hypervisor entry point      |
| 03:20–05:15 | Management network              | explain vSwitch-MGMT and SOC core services                     |
| 05:15–06:35 | Firewall boundary               | explain OPNsense as the segmentation and policy control point  |
| 06:35–08:05 | EnterpriseNet segment           | explain user and workload simulation zone                      |
| 08:05–09:20 | IDS monitoring segment          | explain Security Onion and monitoring enclave role             |
| 09:20–10:45 | Data flow                       | explain detection, logging, analysis, and response flow        |
| 10:45–12:15 | Enterprise role mapping         | connect lab components to enterprise switch and security roles |
| 12:15–13:50 | Security value and SOC workflow | explain why the design matters operationally                   |
| 13:50–15:00 | Closing recap                   | summarize architecture and instructional takeaway              |

---

# 2. Detailed Instructor Cue Sheet

## 00:00–00:55 — Opening

### On-Screen Action

Show the full topology diagram centered on screen. No zoom yet.

### Instructor Says

"In this video, we’re going to walk through the NetStack architecture, which is the enterprise-style network topology and SOC environment used in this lab.

The goal is to understand not only what systems exist, but how the environment is segmented, how traffic flows, where security monitoring takes place, and how the design maps to real enterprise networking and SOC operations.

This is a defensive architecture walkthrough. We’re looking at it the way a security administrator, SOC analyst, or network engineer would explain it."

### Instructor Notes

* Keep the whole diagram visible.
* Do not point to specific devices yet.
* Establish that this is an architecture explanation, not a command-line demo.

---

## 00:55–02:10 — Topology Overview

### On-Screen Action

Use pointer or cursor to trace from top to bottom of the diagram without zooming in too far.

### Instructor Says

"At a high level, this environment is a segmented SOC lab built on a single Ubuntu KVM hypervisor.

The architecture follows a hierarchical star model. At the top, we have the upstream internet connection and home router. Below that is the Ubuntu host, which provides the virtualization platform and the virtual switching infrastructure.

From there, the environment enters the management network, where the core SOC tooling lives. That management segment connects into the OPNsense firewall, which acts as the internal control boundary. Below the firewall, the design branches into two major internal zones: the enterprise workload network and the IDS monitoring network.

That structure is what gives the lab its enterprise character. It is not a flat network. It is organized into zones, each with a defined role."

### Pause Points

* Pause 2 seconds after tracing the full path.
* Pause 2 seconds after mentioning the three main internal zones.

### Instructor Notes

* Keep the explanation conceptual.
* Reinforce that segmentation is the key idea.

---

## 02:10–03:20 — Edge and Upstream Layer

### On-Screen Action

Zoom into the top section of the diagram showing Internet, ISP/Home Router, Ubuntu Host, and Analyst Laptop access path.

### Instructor Says

"At the top of the design is the edge and upstream connectivity layer.

The internet connects into the ISP or home router at `192.168.1.1`. That device serves as the upstream gateway for the environment. In enterprise terms, this plays the role of a WAN edge or branch internet gateway.

Below that is the Ubuntu host running KVM, shown here at `192.168.1.46`, with a Tailscale VPN address providing an additional remote administrative access path.

This host is more than just a laptop. Architecturally, it functions as the virtualization node and physical substrate for the lab. It hosts the virtual machines, supports the virtual switches, and provides the compute layer for the SOC environment.

Off to the side, the analyst laptop represents the remote operator or SOC analyst accessing the environment over a controlled remote path."

### Pause Points

* Pause 2 seconds on the router.
* Pause 3 seconds on the Ubuntu host.
* Pause 2 seconds on the analyst laptop path.

### Instructor Notes

* Emphasize that the hypervisor is acting like compact enterprise infrastructure.
* Mention remote access as administrative, not general user access.

---

## 03:20–05:15 — Management Network

### On-Screen Action

Zoom into `vSwitch-MGMT` and the attached SOC services: Wazuh, Splunk, Ansible Control Node, and optionally the SOAR node if included in the documentation.

### Instructor Says

"This next layer is the management and SOC services network, represented by `vSwitch-MGMT` on the `192.168.122.0/24` subnet.

This is one of the most important segments in the lab because it contains the security operations tooling and the administrative control plane.

On this network, Wazuh provides host-based monitoring and alerting. Splunk provides centralized log analytics and investigation capability. The Ansible control node provides infrastructure automation and repeatable response actions. And, where included, a SOAR or orchestration component such as n8n can connect detections to automated workflows.

In enterprise terms, this segment behaves like a management VLAN or SOC services access network. It is where the analyst-facing and control-plane systems live, and it should be protected accordingly."

### Pause Points

* Pause 2 seconds on `vSwitch-MGMT`.
* Pause 2 seconds each on Wazuh, Splunk, and Ansible.
* Pause 2 seconds on the subnet label.

### Instructor Notes

* Keep the focus on roles, not product marketing.
* Stress that this is the protected operational heart of the environment.

---

## 05:15–06:35 — Firewall Boundary

### On-Screen Action

Center the OPNsense firewall VM and the connection between management and downstream internal segments.

### Instructor Says

"At the center of the architecture is the OPNsense firewall VM, with its management-side interface shown at `192.168.122.254`.

This is the key policy enforcement point in the design. It routes traffic between internal zones and applies firewall rules that determine which segments can communicate and under what conditions.

Without this firewall, the lab would behave much more like a flat virtual network. With it, the environment becomes segmented and policy-driven.

In enterprise language, this is functioning as an internal segmentation firewall or distribution-layer security boundary. It is the place where trust zones are separated and east-west traffic is controlled."

### Pause Points

* Pause 3 seconds on the firewall icon.
* Pause 2 seconds on the WAN-side address label.
* Pause 2 seconds on the downstream branch points.

### Instructor Notes

* This is the architectural centerpiece; give it emphasis.
* Do not overcomplicate the explanation with firewall syntax or rule examples here.

---

## 06:35–08:05 — EnterpriseNet Segment

### On-Screen Action

Zoom into `vSwitch-ENTERPRISENET`, its subnet label `192.168.50.0/24`, and the connected Windows/Linux clients and servers.

### Instructor Says

"On the left side below the firewall is `vSwitch-ENTERPRISENET`, the enterprise workload segment on `192.168.50.0/24`.

This part of the lab simulates the internal corporate environment. It represents employee workstations, internal servers, and normal enterprise application traffic.

Its purpose is to generate realistic workload activity and security telemetry. That gives the monitoring stack something meaningful to observe and analyze.

In enterprise networking terms, this is the access layer or enterprise endpoint network. It is where production-like client and server traffic originates, and it is the zone most likely to generate the events that the SOC investigates."

### Pause Points

* Pause 2 seconds on the virtual switch name.
* Pause 2 seconds on the subnet label.
* Pause 3 seconds on the endpoints and servers.

### Instructor Notes

* Frame this as the traffic-generating business network.
* Use the phrase “simulated enterprise workload” to keep it precise.

---

## 08:05–09:20 — IDS Monitoring Segment

### On-Screen Action

Shift to `vSwitch-IDS`, its subnet label `192.168.70.0/24`, and Security Onion.

### Instructor Says

"On the right side is the IDS monitoring segment, represented by `vSwitch-IDS` on `192.168.70.0/24`.

This is the dedicated monitoring enclave. Its job is to host network security monitoring tools and give the SOC visibility into traffic and suspicious activity.

The primary platform shown here is Security Onion, which provides network security monitoring capabilities such as Suricata, Zeek, and packet capture.

In enterprise terms, this segment behaves like a monitoring or sensor network, comparable to a SPAN, TAP, or packet visibility zone that supports IDS and network detection workflows."

### Pause Points

* Pause 2 seconds on `vSwitch-IDS`.
* Pause 2 seconds on the subnet label.
* Pause 3 seconds on Security Onion.

### Instructor Notes

* If the diagram and deployment notes differ on the exact IP for Security Onion, avoid stating the address unless already standardized.
* Keep the emphasis on function: monitoring, inspection, and alerting.

---

## 09:20–10:45 — Data Flow

### On-Screen Action

Zoom back out enough to show EnterpriseNet, IDS, management services, and the firewall together. Trace the data path using the cursor.

### Instructor Says

"Now let’s look at the operational and security data flow.

Normal enterprise activity begins in the enterprise workload segment, where clients and internal services generate user and application traffic. That traffic crosses the internal architecture through the firewall boundary according to policy.

At the same time, host-based and network-based monitoring systems observe activity. Wazuh contributes host-level telemetry. Security Onion contributes network-level visibility. Those detections and events are then centralized into Splunk for aggregation, correlation, and investigation.

From there, the analyst can investigate manually, or an automation workflow can be triggered. Ansible or a SOAR platform can then execute remediation actions such as firewall changes, notification actions, or other controlled response steps.

This is what makes the architecture operationally complete. It is not just segmented. It supports detection, analysis, and response."

### Pause Points

* Pause 2 seconds after tracing from EnterpriseNet to the firewall.
* Pause 2 seconds after highlighting Wazuh and Security Onion.
* Pause 2 seconds after highlighting Splunk.
* Pause 2 seconds after highlighting Ansible or SOAR.

### Instructor Notes

* Describe flow as a lifecycle, not just a path.
* Keep the cursor moving slowly and intentionally.

---

## 10:45–12:15 — Enterprise Role Mapping

### On-Screen Action

Keep the diagram visible and move pointer from component to component while speaking.

### Instructor Says

"A key part of understanding this lab is mapping each virtual component to its enterprise equivalent.

The home router represents the WAN edge. The Ubuntu KVM host represents the virtualization and infrastructure compute node. `vSwitch-MGMT` acts like a management access switch. `vSwitch-ENTERPRISENET` acts like an access-layer enterprise switch. `vSwitch-IDS` acts like a monitoring aggregation or packet visibility switch.

The OPNsense firewall is the internal segmentation firewall. Wazuh functions like a host-based detection platform. Splunk functions like the SIEM and analytics layer. Ansible represents the automation controller. And Security Onion represents the network-based monitoring stack.

Thinking in those terms is what allows a compact single-host lab to be explained accurately in enterprise language."

### Pause Points

* Pause 2 seconds after each major role mapping group.

### Instructor Notes

* This is the translation layer between the lab and real enterprise architecture.
* Keep terminology consistent with the writeups.

---

## 12:15–13:50 — Security Value and SOC Workflow

### On-Screen Action

Show full diagram again. Optionally highlight each zone one at a time: management, enterprise, IDS.

### Instructor Says

"From a security operations perspective, this design has three major strengths.

First, segmentation. The management network, enterprise network, and IDS network are separated by role and trust. That limits unnecessary exposure and makes policy enforcement clearer.

Second, visibility. The environment combines host-based monitoring, network-based monitoring, centralized log analysis, and analyst access.

Third, response capability. Because the environment includes automation and a central enforcement point, it supports repeatable containment and remediation workflows.

That means this lab is useful not just for demonstrating topology, but for practicing the actual SOC cycle: detection, analysis, triage, response, and validation."

### Pause Points

* Pause 2 seconds after each of the three strengths.
* Pause 2 seconds after the SOC lifecycle summary.

### Instructor Notes

* This section should feel like the architectural justification.
* Reinforce why the design is realistic and defensible.

---

## 13:50–15:00 — Closing Recap

### On-Screen Action

Leave the full topology on screen. No more zooming.

### Instructor Says

"To recap, NetStack is a virtualized enterprise-style SOC architecture built on a compact KVM platform.

It starts with an upstream edge connection, uses a dedicated management network for SOC services, relies on an internal segmentation firewall to separate trust zones, simulates enterprise user and server activity on the workload network, and uses a dedicated monitoring enclave for IDS and network visibility.

What makes this architecture enterprise-relevant is not the physical scale. It is the design discipline: segmented zones, defined device roles, centralized monitoring, policy enforcement, and automation-ready response paths.

That is the framework you should use when explaining, documenting, or demonstrating this lab as a realistic defensive security environment."

### Pause Points

* Hold final frame for 2 seconds before ending.

### Instructor Notes

* End cleanly with the diagram still visible.
* No extra commentary after the final line.

---

# 3. Final Presenter Reference

## Visual Walk Order

1. Full topology overview
2. Internet and ISP/Home Router
3. Ubuntu KVM Hypervisor and Tailscale path
4. vSwitch-MGMT
5. Wazuh
6. Splunk
7. Ansible Control Node
8. Optional SOAR node
9. OPNsense Firewall VM
10. vSwitch-ENTERPRISENET and enterprise clients/servers
11. vSwitch-IDS and Security Onion
12. Full-path data flow across the environment
13. Full topology recap

## Terminology Standard

Use these terms consistently during recording:

* management network
* enterprise workload network
* IDS monitoring network
* internal segmentation firewall
* centralized logging and analytics
* automation and response layer
* enterprise-equivalent role mapping
* defensive SOC architecture

## Closing Standard

The presenter should finish with the full diagram on screen and no additional commentary after the final recap line.
