@load base/protocols/http

event http_entity_data(c: connection, is_orig: bool, length: count, data: string)
{
    if ( /reg add|sc create|schtasks|rundll32|mshta/i in data )
        print fmt("APTPACK_PE_LOLBIN src=%s dst=%s", c$id$orig_h, c$id$resp_h);
}
