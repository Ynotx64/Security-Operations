# Test Cases

## TC-01 Password Spray Against Privileged Test Account
Objective: Trigger a spray threshold using repeated failures.
Expected Result: Password spray detection fires.

## TC-02 Successful Privileged Sign-In After Failure Burst
Objective: Validate suspicious successful login after repeated failures.
Expected Result: Correlation or investigative query returns the event sequence.

## TC-03 Mailbox Rule Creation
Objective: Create a benign mailbox rule in a test tenant or lab mailbox.
Expected Result: Rule creation is logged and detected.

## TC-04 Mail Access / Search Spike
Objective: Generate repeated mail-access or search operations in a test mailbox.
Expected Result: Collection-oriented query returns the spike.

## TC-05 MSP / Delegated Admin Baseline Deviation
Objective: Sign in with a delegated or simulated admin identity from a rare source.
Expected Result: Admin anomaly query returns the event.

## TC-06 Engineering Portal Access From New Source Context
Objective: Access a test portal from a new IP or ASN context.
Expected Result: Portal access anomaly query surfaces the event.

## TC-07 Ubuntu 24.04 Hardening Verification
Objective: Confirm baseline hardening on Linux support hosts.
Expected Result: UFW, fail2ban, auditd, and SSH policy align with playbook settings.
