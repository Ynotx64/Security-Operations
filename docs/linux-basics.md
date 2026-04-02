# Linux Basics for a Security-Focused Workflow

This guide is a practical command-line reference for understanding a Linux system, checking its configuration, maintaining it, verifying basic integrity, and safely exploring the local network.

The focus is **defensive/security operations**, not exploitation. The goal is to help you quickly answer:

* What machine am I on?
* What OS, kernel, users, services, and packages are present?
* Is the system updated?
* What files, permissions, and logs matter?
* What network am I connected to?
* What hosts and services are visible from here?

---

## 1. Core mindset

Before running commands:

* Know whether you are a normal user or root.
* Prefer **read-only inspection first**.
* Use `sudo` only when needed.
* Document what you observe.
* On production or sensitive systems, avoid noisy scans.

Helpful habits:

```bash
whoami
id
hostname
pwd
history | tail
```

What these tell you:

* `whoami` → current username
* `id` → UID, GID, group memberships
* `hostname` → machine name
* `pwd` → current working directory
* `history | tail` → recent command history

---

## 2. Identify the system you are on

### OS and kernel

```bash
uname -a
cat /etc/os-release
hostnamectl
```

Use these to identify:

* Distribution and version
* Kernel version
* Architecture
* Hostname
* Virtualization status if available

### Hardware and CPU

```bash
lscpu
free -h
lsblk
df -h
sudo fdisk -l
```

What to look for:

* CPU model and number of cores
* Available RAM and swap
* Disk layout
* Mounted partitions
* Space usage

### PCI, USB, and attached hardware

```bash
lspci
lsusb
```

Useful for quickly identifying:

* Network adapters
* Storage controllers
* Virtual devices
* USB peripherals

---

## 3. Understand users, privileges, and login context

### Current identity and privilege level

```bash
whoami
id
groups
sudo -l
```

### Logged-in users and past logins

```bash
who
w
last
lastlog
```

### Local user accounts

```bash
cat /etc/passwd
sudo cat /etc/shadow
getent passwd
```

### Accounts with shell access

```bash
grep -E '/bin/bash|/bin/sh|/zsh' /etc/passwd
```

### Check for administrative group membership

```bash
getent group sudo
getent group wheel
```

Security relevance:

* Who can log in?
* Who has sudo?
* Are there unexpected service or human accounts?
* Are old accounts still active?

---

## 4. Inspect processes, services, and startup behavior

### Running processes

```bash
ps aux
ps -ef
top
htop
```

### Find suspicious or interesting processes

```bash
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head
pgrep -a ssh
pgrep -a python
pgrep -a docker
```

### Services and systemd

```bash
systemctl list-units --type=service --state=running
systemctl list-unit-files --type=service
systemctl status ssh
systemctl status NetworkManager
```

### Startup persistence locations

```bash
systemctl list-unit-files --state=enabled
ls -la /etc/systemd/system/
ls -la /usr/lib/systemd/system/
ls -la /etc/cron.d/
ls -la /etc/cron.daily/
crontab -l
sudo crontab -l
```

Why this matters:

* You learn what starts automatically.
* You can spot unexpected services.
* You can identify persistence mechanisms.

---

## 5. Package management and updates

Keep the system current, especially in a security workflow.

### Debian/Ubuntu systems

```bash
sudo apt update
apt list --upgradable
sudo apt upgrade
sudo apt full-upgrade
```

### Review installed packages

```bash
dpkg -l | less
apt list --installed | less
```

### Find a package that owns a file

```bash
dpkg -S /bin/ls
```

### RPM-based systems

```bash
sudo dnf check-update
sudo dnf upgrade
rpm -qa | less
rpm -qf /bin/ls
```

Security practice:

* Check for updates regularly.
* Remove unnecessary packages.
* Pay attention to browser, OpenSSH, kernel, container, and network tooling updates.

---

## 6. File system navigation and permissions

### Essential navigation

```bash
pwd
ls -lah
cd /etc
cd /var/log
cd ~
find . -maxdepth 2 -type f | head
```

### Ownership and permissions

```bash
ls -l
stat /etc/passwd
namei -l /etc/ssh/sshd_config
```

### Permission changes

```bash
chmod 600 file.txt
chmod 700 script.sh
chown user:user file.txt
```

### Find world-writable files and directories

```bash
find / -xdev -type d -perm -0002 2>/dev/null
find / -xdev -type f -perm -0002 2>/dev/null
```

### Find SUID and SGID files

```bash
find / -xdev -perm -4000 -type f 2>/dev/null
find / -xdev -perm -2000 -type f 2>/dev/null
```

Security relevance:

* World-writable locations may be abused.
* SUID/SGID binaries can be sensitive.
* Misconfigured ownership often signals risk.

---

## 7. File integrity and hashing

For integrity checking, use hashes and package verification.

### Generate hashes

```bash
sha256sum file.iso
sha256sum /bin/ls
md5sum file.txt
```

### Compare two directory trees with hashes

```bash
find /etc -type f -exec sha256sum {} \; > etc-hashes.txt
```

### Verify package-managed files on Debian-like systems

```bash
dpkg -V
```

### Verify package-managed files on RPM systems

```bash
rpm -Va
```

### Check timestamps for modified files

```bash
find /etc -type f -mtime -7
find /usr/bin -type f -mtime -7
```

### Useful integrity tools

```bash
sudo apt install aide
sudo aideinit
```

Conceptually:

* Hashes help verify one file.
* Package verification helps detect altered packaged files.
* AIDE helps detect long-term file changes.

---

## 8. Logs and system events

Logs are one of the fastest ways to understand a host.

### Systemd journal

```bash
journalctl -xe
journalctl -b
journalctl -u ssh
journalctl --since "today"
```

### Traditional logs

```bash
ls -lah /var/log
sudo tail -n 50 /var/log/auth.log
sudo tail -n 50 /var/log/syslog
sudo tail -n 50 /var/log/kern.log
```

On some systems:

```bash
sudo tail -n 50 /var/log/secure
sudo tail -n 50 /var/log/messages
```

### Failed login attempts

```bash
sudo grep -i "failed" /var/log/auth.log
sudo grep -i "invalid user" /var/log/auth.log
lastb
```

What to look for:

* Failed SSH attempts
* Service crashes
* New interfaces appearing
* Unusual reboots
* Authentication anomalies

---

## 9. Network basics: understand your host's network position

### Interfaces and addresses

```bash
ip addr
ip -br addr
ip link
```

### Routing

```bash
ip route
route -n
```

### DNS configuration

```bash
cat /etc/resolv.conf
resolvectl status
```

### ARP / neighbor table

```bash
ip neigh
arp -a
```

### Listening ports and connections

```bash
ss -tulpen
ss -tpn
netstat -tulpen
```

These commands answer:

* Which interfaces exist?
* What IPs are assigned?
* What is the default gateway?
* Which DNS servers are configured?
* What services are listening locally?
* What remote connections are active?

---

## 10. Safe network probing and environment discovery

Use these carefully and only on networks you are authorized to inspect.

### Test reachability

```bash
ping -c 4 8.8.8.8
ping -c 4 gateway-ip
```

### DNS lookups

```bash
dig example.com
host example.com
nslookup example.com
```

### Trace path

```bash
traceroute example.com
tracepath example.com
```

### Quick scan with Nmap

#### Ping sweep of local subnet

```bash
nmap -sn 192.168.1.0/24
```

#### Service discovery on one host

```bash
nmap -sV 192.168.1.10
```

#### Common TCP ports only

```bash
nmap -Pn --top-ports 20 192.168.1.10
```

#### More detailed but still common defensive enumeration

```bash
sudo nmap -sS -sV -O 192.168.1.10
```

### Check open ports from your own system outward

```bash
nc -vz 192.168.1.10 22
nc -vz 192.168.1.10 80
```

Important note:

* `nmap -sn` is low-noise host discovery.
* `-sV` grabs service banners.
* `-O` attempts OS detection and is noisier.
* Use scans deliberately.

---

## 11. SSH and remote administration hygiene

### Review SSH client/server basics

```bash
ssh user@host
ssh -i ~/.ssh/id_ed25519 user@host
scp file.txt user@host:/tmp/
```

### Check SSH server config

```bash
sudo grep -v '^#' /etc/ssh/sshd_config | sed '/^$/d'
sudo systemctl status ssh
```

Look for:

* Whether root login is allowed
* Whether password authentication is enabled
* Which users can log in
* Which port SSH listens on

Helpful hardening settings often include:

* `PermitRootLogin no`
* `PasswordAuthentication no`
* `PubkeyAuthentication yes`
* `AllowUsers <approved-user>`

After changes:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

---

## 12. Basic host hardening checks

### Firewall status

Ubuntu/Debian with UFW:

```bash
sudo ufw status verbose
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Firewalld systems:

```bash
sudo firewall-cmd --state
sudo firewall-cmd --list-all
```

### Automatic security updates

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

### Audit sudo usage and sensitive groups

```bash
getent group sudo
getent group adm
getent group docker
```

### Review mounted filesystems

```bash
mount
cat /etc/fstab
```

Look for secure options where applicable:

* `nodev`
* `nosuid`
* `noexec`

### Check kernel security settings

```bash
sysctl -a | grep kernel
sysctl net.ipv4.ip_forward
sysctl net.ipv4.conf.all.rp_filter
```

### Check whether SELinux or AppArmor is active

```bash
getenforce
sestatus
aa-status
```

---

## 13. Useful directories to know in security work

### System configuration

```bash
/etc
```

### Logs

```bash
/var/log
```

### User homes

```bash
/home
/root
```

### Temporary locations

```bash
/tmp
/var/tmp
/dev/shm
```

### Binaries and services

```bash
/usr/bin
/usr/sbin
/lib/systemd/system
/etc/systemd/system
```

### Web and application data

Common examples:

```bash
/var/www
/opt
/srv
```

These locations often help you understand what the machine is for.

---

## 14. Fast triage checklist for a new Linux host

When you land on a system and want a quick profile, run:

```bash
whoami
id
hostnamectl
cat /etc/os-release
uname -a
ip -br addr
ip route
ss -tulpen
ps aux --sort=-%mem | head
systemctl list-units --type=service --state=running
last -n 10
df -h
lsblk
sudo ufw status verbose
journalctl -b -p warning
```

This gives a compact view of:

* identity
* OS and kernel
* addressing and routing
* listening ports
* major services
* recent users
* storage
* firewall status
* warnings in current boot logs

---

## 15. Example workflow: understand the device and network architecture

A practical sequence:

### Step 1: Identify the host

```bash
hostnamectl
cat /etc/os-release
uname -a
```

### Step 2: Identify local users and admin access

```bash
whoami
id
sudo -l
getent group sudo
```

### Step 3: Understand storage and mounted filesystems

```bash
lsblk
findmnt
df -h
```

### Step 4: Understand processes and startup services

```bash
ps aux | head -20
systemctl list-units --type=service --state=running
systemctl list-unit-files --state=enabled
```

### Step 5: Map the host on the network

```bash
ip -br addr
ip route
cat /etc/resolv.conf
ip neigh
ss -tulpen
```

### Step 6: Learn the surrounding network

```bash
ping -c 4 <gateway>
nmap -sn <subnet>/24
nmap -sV <important-host>
```

### Step 7: Verify update and security state

```bash
sudo apt update
apt list --upgradable
sudo ufw status verbose
journalctl -xe
find / -xdev -perm -4000 -type f 2>/dev/null
```

This sequence usually gives a strong first-pass understanding of both the host and its local environment.

---

## 16. Commands worth memorizing first

```bash
pwd
ls -lah
cd
cat
less
grep
find
ip addr
ip route
ss -tulpen
ps aux
systemctl status
journalctl -b
uname -a
cat /etc/os-release
sha256sum
sudo apt update
sudo apt upgrade
nmap -sn
```

These cover navigation, inspection, services, logs, integrity, updates, and network discovery.

---

## 17. Safety notes

* Only scan systems and networks you own or are explicitly authorized to assess.
* Run service/version detection sparingly on sensitive networks.
* Treat logs, hashes, and package verification as baseline defensive tools.
* Avoid making changes before you understand the host role.
* Record findings as you go.

---

## 18. Suggested practice routine

On a Linux VM or lab machine, practice this sequence until it feels natural:

```bash
whoami
id
hostnamectl
cat /etc/os-release
ip -br addr
ip route
ss -tulpen
ps aux --sort=-%mem | head
systemctl list-units --type=service --state=running
journalctl -b | tail -n 30
lsblk
df -h
sudo apt update
sha256sum /bin/ls
nmap -sn 192.168.1.0/24
```

That gives you a repeatable baseline workflow for host and network awareness.

---

## 19. Final objective

For a security-focused Linux workflow, you want to build muscle memory in five areas:

1. **Host identity** — who, what OS, what kernel, what hardware
2. **Privilege and access** — users, sudo, SSH, services
3. **Integrity and maintenance** — updates, logs, package/file verification
4. **Local visibility** — filesystems, processes, listening ports
5. **Network awareness** — interfaces, routes, neighbors, reachable hosts, visible services

Master those first, and the command line stops feeling abstract and starts feeling like a system inspection console.
