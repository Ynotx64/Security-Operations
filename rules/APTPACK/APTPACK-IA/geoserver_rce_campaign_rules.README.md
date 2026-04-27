# geoserver_rce_campaign_rules.xml

## Purpose
Campaign-oriented web detection rule set for GeoServer targeting and likely exploit activity observed at the HTTP request layer.

## Detection scope
This ruleset is intended to detect:
- GeoServer endpoint targeting
- exploit-shaped request content
- repeated malicious request behavior from the same source

## ATT&CK scope
Primary ATT&CK coverage includes:
- T1190 Exploit Public-Facing Application

## Telemetry dependency
This ruleset depends on:
- `web-accesslog` decoding
- URL field extraction
- request content visibility in the web access event

## Deployment notes
This ruleset should be deployed where GeoServer is exposed or where Apache / reverse proxy access logs preserve URI and exploit content indicators. Correct decoder support is required for URL-based matching.

## SOC use
This ruleset supports pre-exploitation and exploitation-stage detection for GeoServer-focused intrusion attempts and campaign tracking.
