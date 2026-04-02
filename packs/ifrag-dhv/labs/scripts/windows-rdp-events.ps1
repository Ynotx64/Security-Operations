# Benign validation script for Windows RDP-related telemetry checks
Write-Host "Review Security events 4624/4625 with Logon Type 10 after your manual test."
Get-WinEvent -LogName Security -MaxEvents 50 |
  Where-Object { $_.Id -in 4624,4625 } |
  Select-Object TimeCreated, Id, ProviderName, Message
