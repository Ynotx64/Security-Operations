# local_decoder.xml

## Purpose
Local decoder placeholder and extension point for custom parsing logic.

## Detection scope
This file currently serves as a local decoder entry point rather than a completed production parser.

## Telemetry dependency
Depends on the log source eventually being mapped to a custom decoder structure.

## Deployment notes
This file should be expanded only when a custom log source requires field extraction beyond default Wazuh decoders.

## SOC use
Provides the parser branch where future custom telemetry extraction can be maintained.
