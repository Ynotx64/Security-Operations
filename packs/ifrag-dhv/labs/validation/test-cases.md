# Test Cases

## TC-01 Windows RDP Brute Force
Objective: Trigger detection for repeated failed RDP logons.
Expected Result: Brute-force alert after threshold is exceeded.

## TC-02 Windows Successful RDP After Failures
Objective: Generate repeated failed logons followed by a successful RDP login.
Expected Result: Correlation alert for suspicious success after failures.

## TC-03 Linux XRDP Authentication Failures
Objective: Produce multiple failed XRDP login attempts.
Expected Result: XRDP failure threshold alert and optional fail2ban action.

## TC-04 Ubuntu 24.04 Hardening Verification
Objective: Confirm UFW, SSH restrictions, unattended upgrades, and XRDP state match policy.
Expected Result: Host configuration aligns with playbook policy.

## TC-05 macOS RDP Client Execution
Objective: Launch an approved RDP client from a test macOS host.
Expected Result: Process creation visibility is present and the query returns the event.
