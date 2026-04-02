rule apt31_mail_rule_and_admin_abuse_artifacts
{
    meta:
        description = "Heuristic detection for scripts or artifacts associated with mailbox rule abuse, spraying, and admin portal targeting"
        author = "OpenAI"
        reference = "APT-31 pack"
        severity = "medium"

    strings:
        $s1 = "New-InboxRule" ascii wide
        $s2 = "Set-InboxRule" ascii wide
        $s3 = "MailItemsAccessed" ascii wide
        $s4 = "SearchQueryInitiated" ascii wide
        $s5 = "Connect-ExchangeOnline" ascii wide
        $s6 = "graph.microsoft.com" ascii wide
        $s7 = "password spray" ascii wide
        $s8 = "engineering portal" ascii wide
        $s9 = "delegated admin" ascii wide

    condition:
        3 of ($s*)
}
