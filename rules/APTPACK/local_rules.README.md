# local_rules.xml

## Purpose
Local override rule file used for targeted suppression or tuning during controlled validation and demo workflows.

## Detection scope
The current active content suppresses noisy sudo-related alerts during GeoServer campaign demo validation.

## ATT&CK scope
Current content is tuning-oriented and not intended as primary ATT&CK detection content. It affects visibility around:
- T1548 Abuse Elevation Control Mechanism

## Telemetry dependency
This file depends on the existing local Wazuh rule loading path and any upstream sudo-related rule logic being overridden.

## Deployment notes
This file should be reviewed carefully before GitHub publication because it contains suppression logic rather than net-new detection logic. It should be documented as environment-specific tuning content.

## SOC use
Useful for demo cleanup and noise reduction, but not a standalone adversary detection pack.
