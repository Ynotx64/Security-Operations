# Script 1 — Linux Basics for a Security Workflow

## Format

**Strict Instructor Cue Sheet with Timestamps**

## Video Title

**Linux Basics for a Security Workflow: Host Inspection, Integrity Checks, and Safe Network Discovery**

## Total Target Runtime

**15:00**

## Delivery Standard

* speak clearly and at a measured pace
* pause after each command output appears
* do not improvise beyond brief natural transitions
* keep cursor movement minimal during explanations
* let the terminal output stay visible long enough to be read

## Recording Assumptions

* Linux terminal already open
* demo is performed on an authorized lab system
* presenter has sudo access
* optional tools such as `nmap`, `dnsutils`, and `htop` are installed

---

# 1. Cue Sheet Overview

| Time        | Segment                        | Objective                                              |
| ----------- | ------------------------------ | ------------------------------------------------------ |
| 00:00–00:50 | Opening                        | establish purpose and scope                            |
| 00:50–02:40 | Host identification            | identify OS, kernel, hostname, and user context        |
| 02:40–04:30 | Users and privileges           | inspect user identity, groups, sudo, and login context |
| 04:30–06:40 | Processes and services         | inspect runtime activity and persistence               |
| 06:40–08:10 | Packages and updates           | review package state and update visibility             |
| 08:10–10:20 | Files, mounts, and permissions | inspect storage and security-relevant permissions      |
| 10:20–11:40 | Integrity checks               | introduce hashes and package verification              |
| 11:40–12:50 | Logs                           | review recent host activity                            |
| 12:50–14:10 | Network position and exposure  | inspect interfaces, routes, DNS, and listening ports   |
| 14:10–15:00 | Safe discovery and closing     | demonstrate controlled discovery and recap             |

---

# 2. Detailed Instructor Cue Sheet

## 00:00–00:50 — Opening

### On-Screen Action

Terminal visible at shell prompt in home directory.

### Instructor Says

"In this video, we’re going to walk through essential Linux basics for a security-focused workflow. The goal is to inspect a Linux system from the command line, understand what machine we are on, review its current state, check services and logs, and then understand how that host sits on the network.

This is defensive system visibility, not offensive activity. We’re building a repeatable workflow that helps us understand a system like an administrator."

### Instructor Notes

* No typing yet.
* Keep the terminal still.
* Start with a calm, deliberate tone.

---

## 00:50–02:40 — Host Identification

### On-Screen Action

Type and run each command separately:

```bash
pwd
whoami
id
hostname
hostnamectl
uname -a
cat /etc/os-release
```

### Instructor Says

"The first thing I want to establish is host identity.

`pwd` shows my current working directory. `whoami` shows the active user. `id` gives a more complete view of identity, including user ID, group ID, and group memberships.

`hostname` shows the machine name, while `hostnamectl` gives a more structured system summary, often including the operating system, kernel, architecture, and virtualization details.

`uname -a` gives kernel and architecture information, and `/etc/os-release` tells us the Linux distribution and version.

Before checking anything else, I want to know exactly what machine I’m on and what operating system I’m dealing with."

### Pause Points

* Pause 2 seconds after `id`.
* Pause 3 seconds after `hostnamectl`.
* Pause 2 seconds after `cat /etc/os-release`.

### Instructor Notes

* Point visually to group memberships if they appear relevant.
* Do not explain every field in `uname -a`; summarize only.

---

## 02:40–04:30 — Users and Privileges

### On-Screen Action

Run:

```bash
groups
sudo -l
who
w
last -n 5
getent passwd | tail
getent group sudo
getent group wheel
```

### Instructor Says

"Once the host is identified, the next question is privilege.

`groups` shows the current user’s group memberships. `sudo -l` shows whether this account has administrative rights and what commands it is allowed to run.

`who` and `w` show who is currently logged in and what sessions are active. `last` gives us recent login history.

`getent passwd` gives us account entries in a standard format, and `getent group sudo` or `getent group wheel` helps identify administrative groups depending on the distribution.

In security administration, privilege context matters immediately. I want to know who has access, who is active, and whether this account can administer the system."

### Pause Points

* Pause 3 seconds after `sudo -l`.
* Pause 2 seconds after `w`.
* Pause 2 seconds after `last -n 5`.

### Instructor Notes

* If `sudo -l` prompts for a password, say: "That prompt is normal on many systems."
* If `wheel` is empty, note that Debian and Ubuntu often use the `sudo` group instead.

---

## 04:30–06:40 — Processes and Services

### On-Screen Action

Run:

```bash
ps aux | head
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head
systemctl list-units --type=service --state=running
systemctl list-unit-files --state=enabled | head -n 25
```

Optional:

```bash
htop
```

### Instructor Says

"Now we inspect what the host is doing.

`ps aux` shows running processes. Sorting by memory and CPU usage gives a quick way to identify heavier or more active workloads.

`systemctl list-units` shows services that are currently running. `systemctl list-unit-files --state=enabled` shows services configured to start automatically.

That distinction matters. A process tells me what is active right now. An enabled service tells me what persists across reboots.

As an administrator, I want to understand both the current runtime state and the startup behavior of the system."

### Pause Points

* Pause 2 seconds after each `ps` command.
* Pause 3 seconds after listing running services.
* Pause 3 seconds after listing enabled units.

### Instructor Notes

* If SSH or networking services appear, point them out briefly.
* If using `htop`, keep it open no more than 8 seconds, then exit.

---

## 06:40–08:10 — Packages and Updates

### On-Screen Action

Run:

```bash
sudo apt update
apt list --upgradable
apt list --installed | head -n 25
```

Optional:

```bash
dpkg -l | head -n 25
```

### Instructor Says

"A secure Linux workflow also includes maintenance and patch awareness.

`apt update` refreshes package metadata so the system knows what updates are available. `apt list --upgradable` shows packages that can be updated. `apt list --installed` gives a quick view of installed software.

This matters because security posture depends not only on configuration, but also on patch level and software footprint.

When I inspect a system, I want to know whether it is current, whether core packages need attention, and whether the installed software matches the role of the host."

### Pause Points

* Pause briefly after `apt update` completes.
* Pause 3 seconds after `apt list --upgradable`.
* Pause 2 seconds after installed package output appears.

### Instructor Notes

* Do not run `upgrade` during the demo unless the video is specifically about patching.
* Mention change control if the system represents production operations.

---

## 08:10–10:20 — Files, Mounts, and Permissions

### On-Screen Action

Run:

```bash
lsblk
df -h
findmnt | head -n 20
ls -lah /etc | head
stat /etc/passwd
namei -l /etc/ssh/sshd_config
find / -xdev -type d -perm -0002 2>/dev/null | head
find / -xdev -perm -4000 -type f 2>/dev/null | head
```

### Instructor Says

"Now we move into file system and permission awareness.

`lsblk` shows block devices and partition structure. `df -h` shows mounted filesystems and usage. `findmnt` gives a structured mount view.

Then we shift to permissions. `stat` shows detailed metadata on a file. `namei -l` is useful because it shows permissions across the full path, not just the final file.

The first `find` command looks for world-writable directories. Some are expected, such as temporary locations, but unexpected results deserve review.

The second `find` command looks for SUID binaries. Those are not automatically a problem, but they are security-relevant because they execute with elevated privileges.

These commands help us understand not just where data lives, but how access is controlled."

### Pause Points

* Pause 2 seconds after `lsblk`.
* Pause 2 seconds after `df -h`.
* Pause 3 seconds after `namei -l`.
* Pause 3 seconds after each `find` result block.

### Instructor Notes

* Briefly explain that `-xdev` keeps the search on one filesystem.
* Mention `/tmp` as a normal world-writable location if it appears.

---

## 10:20–11:40 — Integrity Checks

### On-Screen Action

Run:

```bash
sha256sum /bin/ls
sha256sum /etc/passwd
find /etc -maxdepth 1 -type f -exec sha256sum {} \; | head
sudo dpkg -V
```

### Instructor Says

"Security administration includes verifying integrity.

`sha256sum` generates a cryptographic hash for a file. If the contents change, the hash changes. That makes hashing useful for integrity verification and baselining.

You can also hash a group of files to create a simple reference point. On Debian-based systems, `dpkg -V` checks package-managed files against package metadata.

This is a useful introduction to the principle that trusted files should be verified rather than assumed."

### Pause Points

* Pause 2 seconds after each individual hash.
* Pause 3 seconds after `dpkg -V`.

### Instructor Notes

* If `dpkg -V` returns no output, say: "No output often means no package verification mismatches were found."

---

## 11:40–12:50 — Logs

### On-Screen Action

Run:

```bash
journalctl -b | tail -n 30
journalctl -u ssh | tail -n 20
sudo tail -n 30 /var/log/auth.log
last -n 10
lastb -n 10
```

### Instructor Says

"Logs are one of the fastest ways to understand host behavior.

`journalctl -b` shows logs from the current boot. `journalctl -u ssh` narrows the view to a specific service, which is especially useful for troubleshooting and access review.

`auth.log` is a common place to inspect authentication activity on Debian and Ubuntu systems. `last` shows successful login history, and `lastb` can show failed login attempts where available.

This is where system state becomes observable behavior."

### Pause Points

* Pause 2 seconds after boot log output.
* Pause 2 seconds after SSH log output.
* Pause 3 seconds after `auth.log` output.

### Instructor Notes

* If `auth.log` does not exist, state that log file locations vary by distribution.
* If `lastb` requires privilege, mention that this is normal.

---

## 12:50–14:10 — Network Position and Exposure

### On-Screen Action

Run:

```bash
ip -br addr
ip route
ip neigh
cat /etc/resolv.conf
resolvectl status
ss -tulpen
ss -tpn
```

### Instructor Says

"Now we move from host inspection into network awareness.

`ip -br addr` gives a concise view of interfaces and addresses. `ip route` shows the routing table, including the default gateway. `ip neigh` shows nearby layer two neighbors the system has learned.

`/etc/resolv.conf` and `resolvectl status` show DNS configuration, which is important for both operations and troubleshooting.

`ss -tulpen` shows listening sockets, and `ss -tpn` shows current network connections.

At this stage, I’m asking: what interfaces exist, how is traffic routed, what name resolution is being used, and what services is this host exposing?"

### Pause Points

* Pause 2 seconds after `ip -br addr`.
* Pause 2 seconds after `ip route`.
* Pause 2 seconds after resolver output.
* Pause 3 seconds after `ss -tulpen`.

### Instructor Notes

* Point out the default gateway if visible.
* Point out any expected service listeners such as SSH.

---

## 14:10–15:00 — Safe Discovery and Closing

### On-Screen Action

Run only in an authorized lab:

```bash
ping -c 4 8.8.8.8
ping -c 4 <gateway-ip>
dig example.com
nmap -sn 192.168.1.0/24
nmap -sV <target-ip>
```

Replace placeholders before recording.

### Instructor Says

"The final step is controlled network discovery.

A ping to a public address helps confirm outbound reachability. A ping to the local gateway helps confirm local network connectivity. `dig` verifies DNS resolution directly.

`nmap -sn` performs host discovery without a full port scan, which is a lower-noise way to identify active systems on a subnet. `nmap -sV` attempts service detection on a specific host.

Use these commands deliberately and only where you are authorized to inspect the network.

To recap, the workflow we used was simple and repeatable: identify the host, understand users and privilege, inspect processes and services, review packages, check permissions and integrity, inspect logs, and then understand the host’s network position and exposure.

That sequence is the foundation of Linux system inspection for security-oriented administration."

### Pause Points

* Pause 2 seconds after each `ping`.
* Pause 2 seconds after `dig`.
* Pause 3 seconds after `nmap -sn`.
* Pause 3 seconds after `nmap -sV`.

### Instructor Notes

* End at the shell prompt.
* Hold the final frame for 2 seconds before cutting.

---

# 3. Final Presenter Reference

## Exact Command Block

```bash
pwd
whoami
id
hostname
hostnamectl
uname -a
cat /etc/os-release

groups
sudo -l
who
w
last -n 5
getent passwd | tail
getent group sudo
getent group wheel

ps aux | head
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head
systemctl list-units --type=service --state=running
systemctl list-unit-files --state=enabled | head -n 25

sudo apt update
apt list --upgradable
apt list --installed | head -n 25

lsblk
df -h
findmnt | head -n 20
ls -lah /etc | head
stat /etc/passwd
namei -l /etc/ssh/sshd_config
find / -xdev -type d -perm -0002 2>/dev/null | head
find / -xdev -perm -4000 -type f 2>/dev/null | head

sha256sum /bin/ls
sha256sum /etc/passwd
find /etc -maxdepth 1 -type f -exec sha256sum {} \; | head
sudo dpkg -V

journalctl -b | tail -n 30
journalctl -u ssh | tail -n 20
sudo tail -n 30 /var/log/auth.log
last -n 10
lastb -n 10

ip -br addr
ip route
ip neigh
cat /etc/resolv.conf
resolvectl status
ss -tulpen
ss -tpn

ping -c 4 8.8.8.8
ping -c 4 <gateway-ip>
dig example.com
nmap -sn 192.168.1.0/24
nmap -sV <target-ip>
```

## Closing Standard

The presenter should finish with the terminal at the prompt and no additional commentary after the final recap line.
