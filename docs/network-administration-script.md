# Script 2 — Enterprise-Style Network Administration for Security

## Format

**Strict Instructor Cue Sheet with Timestamps**

## Video Title

**Enterprise-Style Network Administration for Security: Segmentation, Exposure Validation, and Monitoring**

## Total Target Runtime

**15:00**

## Delivery Standard

* speak clearly and at a measured pace
* pause after each command output appears
* do not improvise beyond brief natural transitions
* keep cursor movement minimal during explanations
* let terminal output remain visible long enough to be read

## Recording Assumptions

* Linux terminal already open
* demo is performed on an authorized lab or administrative environment
* presenter has sudo access
* the environment may include Linux bridges, VLANs, a virtual switch model, or a routed firewall VM
* optional tools such as `nmap`, `tcpdump`, `nmcli`, and `bridge-utils` are installed

---

# 1. Cue Sheet Overview

| Time        | Segment                           | Objective                                                    |
| ----------- | --------------------------------- | ------------------------------------------------------------ |
| 00:00–00:55 | Opening                           | establish enterprise network administration scope            |
| 00:55–02:30 | Host and admin context            | identify the system and confirm administrative viewpoint     |
| 02:30–04:20 | Interfaces and addressing         | inspect interface roles, addresses, and operational state    |
| 04:20–05:50 | Routing and path awareness        | inspect default routes, local routes, and policy routing     |
| 05:50–07:30 | Layer 2 and segmentation context  | inspect neighbors, bridges, and VLAN visibility              |
| 07:30–09:00 | DNS and service exposure          | validate resolver configuration and listening services       |
| 09:00–10:45 | Firewall and policy validation    | inspect local filtering and rule enforcement                 |
| 10:45–12:20 | Services, logs, and observability | confirm network services and logging visibility              |
| 12:20–13:50 | Safe administrative validation    | validate reachability and controlled discovery               |
| 13:50–15:00 | Enterprise recap                  | connect command output to enterprise administration concepts |

---

# 2. Detailed Instructor Cue Sheet

## 00:00–00:55 — Opening

### On-Screen Action

Terminal visible at shell prompt. No typing yet.

### Instructor Says

"In this video, we’re going to walk through enterprise-style network administration from a security perspective. The goal is to understand how to inspect a Linux-based host or administration point and use it to reason about segmentation, routing, service exposure, policy boundaries, and monitoring.

This is not just a list of commands. We are using the command line to think like a network administrator operating in a security-conscious environment."

### Instructor Notes

* Keep the opening direct and professional.
* Set the expectation that the viewer should think in segments, paths, and controls.

---

## 00:55–02:30 — Host and Administrative Context

### On-Screen Action

Run:

```bash
hostnamectl
whoami
id
uname -a
cat /etc/os-release
nmcli device status
```

### Instructor Says

"Before we interpret the network, we need to confirm the administrative context of the system we are on.

`hostnamectl` identifies the machine. `whoami` and `id` confirm the account and privilege context. `uname -a` and `/etc/os-release` identify the operating system and kernel.

Then `nmcli device status` gives a useful operational view of network devices, including whether interfaces are connected, disconnected, or managed.

At the enterprise level, context matters. Before looking at routes or VLANs, I need to know what host I’m on and whether it is functioning as a workstation, admin jump point, server, or infrastructure node."

### Pause Points

* Pause 3 seconds after `hostnamectl`.
* Pause 2 seconds after `id`.
* Pause 3 seconds after `nmcli device status`.

### Instructor Notes

* If `nmcli` is unavailable, substitute `ip link show` and note the tool difference.
* Emphasize that admin context shapes interpretation of the rest of the output.

---

## 02:30–04:20 — Interfaces and Addressing

### On-Screen Action

Run:

```bash
ip -br addr
ip link show
ip addr show
```

### Instructor Says

"Now we inspect interface state and addressing.

`ip -br addr` is the fastest concise view of interfaces and assigned addresses. `ip link show` gives link-layer state, and `ip addr show` gives the full interface detail.

This is where I start asking enterprise questions: which interface is management, which interface is carrying production or enterprise traffic, whether there are bridge interfaces, whether VLAN-tagged interfaces exist, and whether the addressing matches the expected segment design.

At this stage, I’m not just reading IP addresses. I’m identifying network roles."

### Pause Points

* Pause 3 seconds after `ip -br addr`.
* Pause 2 seconds after `ip link show`.
* Pause 3 seconds after `ip addr show`.

### Instructor Notes

* Point out loopback, physical NICs, bridge interfaces, or VLAN subinterfaces if present.
* Keep the interpretation high level rather than line-by-line.

---

## 04:20–05:50 — Routing and Path Awareness

### On-Screen Action

Run:

```bash
ip route
ip route show table main
ip rule show
route -n
```

### Instructor Says

"Once interfaces are understood, the next step is routing.

`ip route` and `ip route show table main` show the active routing table. `ip rule show` helps reveal whether policy routing is in use. `route -n` gives a more traditional route table view that some administrators still find useful.

In enterprise administration, this is where I verify the default gateway, local subnet routes, static routes, and whether traffic to certain destinations may be following a specialized path.

When something is unreachable, the problem is often not the interface itself. It is the path."

### Pause Points

* Pause 3 seconds after `ip route`.
* Pause 2 seconds after `ip rule show`.
* Pause 2 seconds after `route -n`.

### Instructor Notes

* Point out the default route clearly.
* If there are multiple routes or tables, note that path selection may be policy-driven.

---

## 05:50–07:30 — Layer 2 and Segmentation Context

### On-Screen Action

Run:

```bash
ip neigh
arp -a
bridge link
bridge vlan show
brctl show
```

If Open vSwitch is present, also run:

```bash
ovs-vsctl show
```

### Instructor Says

"Now we move into layer two and segmentation visibility.

`ip neigh` and `arp -a` show nearby systems that this host has resolved on the local network. `bridge link` and `bridge vlan show` help us understand Linux bridge membership and VLAN assignment. `brctl show` provides a classic bridge summary where available.

If the environment uses Open vSwitch, `ovs-vsctl show` reveals the virtual switching structure.

This is where a lab starts to look like an enterprise design. Instead of seeing isolated interfaces, we begin to see access networks, bridge domains, and segmentation boundaries represented in software."

### Pause Points

* Pause 2 seconds after `ip neigh`.
* Pause 2 seconds after `bridge link`.
* Pause 3 seconds after `bridge vlan show`.
* Pause 3 seconds after `ovs-vsctl show`, if used.

### Instructor Notes

* If bridge commands return minimal output, explain that results depend on whether the host is actually switching or bridging traffic.
* Relate bridge or VLAN output back to management, enterprise, or security segments.

---

## 07:30–09:00 — DNS and Service Exposure

### On-Screen Action

Run:

```bash
cat /etc/resolv.conf
resolvectl status
getent hosts example.local
host example.com
dig example.com
ss -tulpen
ss -tpn
lsof -i -P -n | head -n 20
```

### Instructor Says

"Next, we validate name resolution and service exposure.

`/etc/resolv.conf` and `resolvectl status` show resolver configuration. `getent hosts`, `host`, and `dig` demonstrate how the system resolves names.

Then `ss -tulpen`, `ss -tpn`, and `lsof -i` help us inspect listening ports and active network connections.

This is important because enterprise administration is not only about network reachability. It is also about confirming that each host is exposing only the services appropriate to its role."

### Pause Points

* Pause 2 seconds after resolver output.
* Pause 2 seconds after `dig`.
* Pause 3 seconds after `ss -tulpen`.
* Pause 2 seconds after `lsof -i`.

### Instructor Notes

* If `example.local` does not resolve, say that internal naming depends on the environment.
* Point out expected listeners such as SSH, web management, or monitoring services if present.

---

## 09:00–10:45 — Firewall and Policy Validation

### On-Screen Action

Run:

```bash
sudo nft list ruleset
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
sudo ufw status verbose
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all
```

### Instructor Says

"A segmented network is only meaningful if policy is actually enforced.

`nft list ruleset` shows nftables policy where nftables is used. The `iptables` commands provide filter and NAT table visibility for systems still using iptables compatibility. `ufw status verbose` and `firewall-cmd` help validate higher-level firewall management layers where those tools are present.

The point is not to memorize every firewall framework. The point is to trace whether local traffic is being filtered, whether address translation is happening, and whether the host’s policy aligns with its intended role.

In enterprise operations, every allowed path should be intentional."

### Pause Points

* Pause 3 seconds after `nft list ruleset`.
* Pause 3 seconds after `iptables -L -n -v`.
* Pause 2 seconds after NAT table output.
* Pause 2 seconds after UFW or firewalld output.

### Instructor Notes

* Not every system will use every firewall tool; note that empty or unavailable results are normal depending on the environment.
* Keep the explanation focused on policy validation, not syntax deep-dives.

---

## 10:45–12:20 — Services, Logs, and Observability

### On-Screen Action

Run:

```bash
systemctl list-units --type=service --state=running
journalctl -b | tail -n 30
journalctl -u NetworkManager | tail -n 20
journalctl -u ssh | tail -n 20
ip -s link
ss -s
```

Optional if installed:

```bash
sar -n DEV 1 5
```

### Instructor Says

"Enterprise administration also requires observability.

First, I confirm what services are actually running. Then I inspect recent logs using `journalctl`, focusing on the current boot and important network-related services such as NetworkManager or SSH.

`ip -s link` gives interface counters, and `ss -s` provides a quick connection summary. If tools such as `sar` are available, they help illustrate short-term network activity.

This matters because a network is not truly administrable unless you can observe service state, interface behavior, and recent operational events."

### Pause Points

* Pause 3 seconds after running services output.
* Pause 2 seconds after each log view.
* Pause 2 seconds after `ip -s link`.
* Pause 2 seconds after `ss -s`.

### Instructor Notes

* If logs are quiet, state that low-noise output can be normal in a stable environment.
* Emphasize that counters and logs help verify behavior over time, not just instant state.

---

## 12:20–13:50 — Safe Administrative Validation

### On-Screen Action

Run only in an authorized environment:

```bash
ping -c 4 <default-gateway>
ping -c 4 8.8.8.8
tracepath example.com
nc -vz <target-ip> 22
nc -vz <target-ip> 443
nmap -sn 192.168.1.0/24
nmap -Pn --top-ports 20 <target-ip>
```

Replace placeholders before recording.

### Instructor Says

"At this stage, we can perform controlled administrative validation.

A ping to the default gateway validates local path health. A ping to a public address helps confirm outbound connectivity. `tracepath` shows how the system reaches a remote destination.

`nc -vz` is a simple way to test whether a specific port is reachable. `nmap -sn` provides host discovery on a subnet, and `nmap -Pn --top-ports 20` gives a restrained service check against a chosen target.

Used carefully and with authorization, these commands help confirm whether the network behaves the way the design says it should."

### Pause Points

* Pause 2 seconds after each ping.
* Pause 2 seconds after `tracepath`.
* Pause 2 seconds after each `nc -vz` test.
* Pause 3 seconds after each `nmap` result.

### Instructor Notes

* Stress authorization clearly.
* Keep scan scope narrow and administrative.
* Do not add aggressive flags.

---

## 13:50–15:00 — Enterprise Recap

### On-Screen Action

Return to terminal prompt. No more typing.

### Instructor Says

"To recap, enterprise-style network administration means thinking in roles, paths, and controls.

We identified the host and its network interfaces, inspected addressing and routing, looked at local layer two context, validated DNS and service exposure, reviewed firewall policy, checked logs and interface statistics, and then performed controlled validation of reachability and exposure.

The important shift is conceptual. We are not just reading Linux output. We are interpreting management networks, enterprise segments, security enclaves, service boundaries, and monitoring paths.

That is the mindset that turns command-line inspection into enterprise network administration for security."

### Pause Points

* Hold final frame for 2 seconds before ending.

### Instructor Notes

* End cleanly at the shell prompt.
* No additional commentary after the last sentence.

---

# 3. Final Presenter Reference

## Exact Command Block

```bash
hostnamectl
whoami
id
uname -a
cat /etc/os-release
nmcli device status

ip -br addr
ip link show
ip addr show

ip route
ip route show table main
ip rule show
route -n

ip neigh
arp -a
bridge link
bridge vlan show
brctl show
ovs-vsctl show

cat /etc/resolv.conf
resolvectl status
getent hosts example.local
host example.com
dig example.com
ss -tulpen
ss -tpn
lsof -i -P -n | head -n 20

sudo nft list ruleset
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
sudo ufw status verbose
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all

systemctl list-units --type=service --state=running
journalctl -b | tail -n 30
journalctl -u NetworkManager | tail -n 20
journalctl -u ssh | tail -n 20
ip -s link
ss -s
sar -n DEV 1 5

ping -c 4 <default-gateway>
ping -c 4 8.8.8.8
tracepath example.com
nc -vz <target-ip> 22
nc -vz <target-ip> 443
nmap -sn 192.168.1.0/24
nmap -Pn --top-ports 20 <target-ip>
```

## Closing Standard

The presenter should finish at the shell prompt with no additional commentary after the final recap line.
