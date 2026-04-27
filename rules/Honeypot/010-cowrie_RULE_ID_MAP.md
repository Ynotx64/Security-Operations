# Cowrie Rule ID Map

## Taxonomy / protocol
- 111100: Cowrie base event
- 111101: Cowrie SSH interaction
- 111102: Cowrie Telnet interaction

## Authentication / session
- 111110: Authentication attempt
- 111111: Authentication failure
- 111112: Authentication success
- 111113: Session lifecycle

## Commands / files
- 111114: Command execution
- 111115: File download / remote retrieval
- 111116: File upload / artifact capture

## Payload / shell / miner / creds
- 111120: Downloader pattern
- 111121: Shell or reverse shell pattern
- 111122: Cryptominer pattern
- 111123: Default credentials
- 111124: Crypto-node targeting / attribution theme

## Correlation
- 111130: Brute-force burst
- 111131: Success after prior activity

## IOC / attribution visualization
- 111140: URL IOC candidate
- 111141: File hash IOC candidate
- 111142: Fingerprinting metadata / attribution candidate
