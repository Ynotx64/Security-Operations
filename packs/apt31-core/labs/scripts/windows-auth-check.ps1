# Review recent Windows authentication events for test accounts
Get-WinEvent -LogName Security -MaxEvents 100 |
  Where-Object { $_.Id -in 4624,4625,4648 } |
  Select-Object TimeCreated, Id, ProviderName, Message
