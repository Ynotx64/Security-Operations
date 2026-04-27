@load base/protocols/http

event http_entity_data(c: connection, is_orig: bool, length: count, data: string)
{
    if ( /frombase64string|powershell.+-enc|cmd\.exe.+\/c/i in data )
        print fmt("APTPACK_EXEC_ENCODED src=%s dst=%s", c$id$orig_h, c$id$resp_h);
}
