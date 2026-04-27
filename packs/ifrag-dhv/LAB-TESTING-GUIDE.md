# Lab Testing Guide - RDP/XRDP Hardening Validation

## Overview

This guide provides a structured approach to validate RDP/XRDP hardening controls and detection capabilities in an isolated lab environment.

## Lab Layout

| System | Purpose | OS |
|--------|---------|-----|
| Attacker/Tester | Initiates login attempts | Any |
| WIN-SRV-01 | Windows RDP target | Windows Server/Desktop |
| UBUNTU-01 | Ubuntu XRDP target | Ubuntu 24.04 |
| LOG-STACK | Centralized logging | Elastic/Splunk/Wazuh |

**Network:** Private subnet (e.g., 192.168.100.0/24), isolated from internet

---

## Phase 1: Hardening Validation

### Ubuntu 24.04 Hardening Checklist

Apply the Ansible playbook, then verify:

```bash
# UFW Configuration
sudo ufw status verbose
# Expected: Status: active, Default deny incoming

# XRDP Status
sudo systemctl status xrdp
# Expected: disabled (unless intentionally enabled for testing)

# Fail2ban
sudo systemctl status fail2ban
# Expected: active (running)

# Auditd
sudo systemctl status auditd
# Expected: active (running)

# SSH Hardening
grep -E 'PermitRootLogin|PasswordAuthentication' /etc/ssh/sshd_config
# Expected: PermitRootLogin no, PasswordAuthentication no (or intentional)

# Auto Updates
cat /etc/apt/apt.conf.d/20auto-upgrades
# Expected: APT::Periodic::Update-Package-Lists "1";

# UFW XRDP Rule (if enabled)
sudo ufw status | grep 3389
# Expected: Allow from <approved_ip> only
```

### Windows Hardening Checklist

Manually verify:

- [ ] RDP enabled only if required
- [ ] Network Level Authentication (NLA) enabled
- [ ] Windows Firewall: 3389 restricted to approved IPs only
- [ ] RDP not exposed to entire subnet

---

## Phase 2: Telemetry Validation

### Windows RDP Events

Generate a normal RDP login and verify in Event Viewer:

| Event ID | Description | Logon Type |
|----------|-------------|-------------|
| 4624 | Successful logon | 10 |
| 4625 | Failed logon | 10 |

**Sysmon (if installed):**
- [ ] Process creation events visible
- [ ] Registry modification events for RDP config

### Ubuntu XRDP Logs

Verify ingestion of:

```bash
# Check XRDP logs exist
ls -la /var/log/xrdp-sesman.log
cat /var/log/xrdp-sesman.log

# Auth logs
tail -f /var/log/auth.log | grep xrdp

# Firewall logs (if enabled)
sudo ufw logging on
tail -f /var/log/ufw.log
```

### macOS RDP Client Visibility

Confirm process telemetry for:
- Microsoft Remote Desktop
- Windows App
- `xfreerdp`
- `rdesktop`

---

## Phase 3: Detection Validation

### TC-01: Windows RDP Brute Force

**Objective:** Trigger brute-force threshold detection

**Target:** WIN-SRV-01  
**Source:** LAB-TEST-01

**Steps:**
1. From tester, attempt 8-10 failed RDP logins within 15 minutes
2. Use valid username, wrong password

**Expected Results:**
- Windows Security Event 4625 (Logon Type 10)
- Elastic: Rule matches
- Splunk: Query returns results
- Wazuh: Alert triggered

**Validation Command:**
```powershell
# Windows PowerShell - check failed logins
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -MaxEvents 10 |
  Where-Object {$_.Message -match 'Logon Type:\s+10'}
```

**Result:** PASS / FAIL
**Notes:** ____________________

---

### TC-02: Successful RDP After Failures

**Objective:** Validate detection of successful login after brute-force

**Steps:**
1. Perform 5 failed RDP attempts
2. Authenticate successfully with correct password

**Expected Results:**
- Sequence: 4625 events → 4624 event
- "Success after failures" detection fires

**Result:** PASS / FAIL
**Notes:** ____________________

---

### TC-03: Windows RDP Configuration Change

**Objective:** Validate config drift detection

**Steps:**
1. Enable RDP (via System Properties)
2. Disable NLA
3. Change firewall rule for 3389
4. Revert all changes

**Expected Results:**
- Registry/config change telemetry visible
- Config change detections trigger

**Result:** PASS / FAIL
**Notes:** ____________________

---

### TC-04: Ubuntu XRDP Auth Failures

**Objective:** Validate XRDP failure detection

**Steps:**
1. Enable XRDP intentionally: `sudo systemctl enable --now xrdp`
2. From tester, attempt 5 failed XRDP logins

**Expected Results:**
- Entries in `/var/log/xrdp-sesman.log`
- fail2ban blocks after configured retries
- Detection rules trigger

**Validation:**
```bash
# Check fail2ban
sudo fail2ban-client status xrdp-sesman
sudo tail -20 /var/log/fail2ban.log

# Check xrdp logs
sudo tail -20 /var/log/xrdp-sesman.log
```

**Result:** PASS / FAIL
**Notes:** ____________________

---

### TC-05: Policy Enforcement - Source IP Filtering

**Objective:** Validate UFW blocks unauthorized sources

**Steps:**
1. Apply playbook with approved source IP list
2. Attempt XRDP from approved IP → Should succeed
3. Attempt XRDP from unapproved IP → Should be blocked by UFW

**Expected Results:**
- Approved source: Connection succeeds
- Unapproved source: UFW denies (port 3389 blocked)

**Validation:**
```bash
# From approved IP
nc -zv <ubuntu_ip> 3389  # Should connect (if XRDP enabled)

# From unapproved IP
nc -zv <ubuntu_ip> 3389  # Should timeout/close
```

**Result:** PASS / FAIL
**Notes:** ____________________

---

### TC-06: macOS RDP Client Execution

**Objective:** Validate client-side visibility

**Steps:**
1. Launch Microsoft Remote Desktop on macOS endpoint
2. Initiate connection to Windows target

**Expected Results:**
- Process telemetry visible in Elastic/Splunk
- Query shows: Microsoft Remote Desktop, xfreerdp, or rdesktop execution

**Elastic Query:**
```json
{
  "query": {
    "match": {
      "process.name": "*remote*desktop*"
    }
  }
}
```

**Splunk SPL:**
```
index=endpoint process_name=*remote* OR process_name=*freerdp*
```

**Result:** PASS / FAIL
**Notes:** ____________________

---

## Phase 4: Tune Thresholds

Based on test results, adjust detection thresholds:

| Detection | Default Threshold | Adjusted | Reason |
|-----------|------------------|----------|--------|
| RDP Brute Force | 8 attempts | ? | ? |
| Fail2ban XRDP | 5 attempts | ? | ? |

---

## Validation Summary

| Test Case | Status | Date Tested | Notes |
|-----------|--------|-------------|-------|
| TC-01 RDP Brute Force | | | |
| TC-02 Success After Failure | | | |
| TC-03 Config Change | | | |
| TC-04 XRDP Failures | | | |
| TC-05 IP Filtering | | | |
| TC-06 macOS Client | | | |

---

## Tools Reference

### RDP Testing Tools (Safe/Benign)

```bash
# xfreerdp (Linux)
xfreerdp /u:username /v:target_ip /p:password
xfreerdp /u:test /v:192.168.100.10  # Will fail auth

# rdesktop (Linux)
rdesktop -u username -p password target_ip

# Windows mstsc
mstsc.exe /v:target_ip
```

### Validation Commands

```bash
# Windows - Failed logins
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -MaxEvents 20

# Windows - Successful logins
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents 10

# Ubuntu - XRDP sesman
tail -f /var/log/xrdp-sesman.log

# Ubuntu - Auth failures
grep -i "failed\|invalid\|error" /var/log/auth.log | tail -20

# fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status xrdp-sesman
```

---

## Appendix: Detection Rule References

### Sigma Rules

- `win_susp_rdp_login_methods.yml`
- `win_rdp_brute_force.yml`
- `sysmon_rdp_reverse_tunnel.yml`

### Elastic Rules

- `RDP Brute Force Detected`
- `Successful RDP Login`

### Splunk Searches

```
# RDP brute force
index=windows Security EventCode=4625 Account_Name!=ANONYMOUS Logon_Type=10 | stats count by IpAddress, Account_Name | where count > 5

# RDP success
index=windows Security EventCode=4624 Logon_Type=10 | stats count by IpAddress, Account_Name
```

---

## Safety Notes

- Use dedicated test accounts in lab
- Disable account lockout policy during testing to avoid interruptions
- Keep lab isolated from production networks
- Use snapshots for quick rollback
- Document all changes made during testing
