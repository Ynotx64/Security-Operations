rule ifrag_dhv_enable_rdp_or_xrdp_artifacts
{
    meta:
        description = "Detects scripts or payloads that enable RDP/XRDP, weaken firewall restrictions, or alter remote access posture"
        author = "OpenAI"
        reference = "ifrag-dhv"
        severity = "high"

    strings:
        $s1 = "fDenyTSConnections" ascii wide
        $s2 = "UserAuthentication" ascii wide
        $s3 = "netsh advfirewall firewall add rule" ascii wide
        $s4 = "TermService" ascii wide
        $s5 = "xrdp.ini" ascii wide
        $s6 = "xrdp-sesman" ascii wide
        $s7 = "ufw allow 3389/tcp" ascii wide
        $s8 = "Set-ItemProperty" ascii wide
        $s9 = "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" ascii wide

    condition:
        3 of ($s*)
}
