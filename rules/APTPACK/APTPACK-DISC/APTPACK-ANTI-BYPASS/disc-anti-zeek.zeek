@load base/protocols/http

event http_entity_data(c: connection, is_orig: bool, length: count, data: string)
{
    if ( /whoami|ipconfig|hostname/i in data && /base64|%20|%2f|%5c/i in data )
        print fmt("APTPACK_DISC_ENCODED src=%s dst=%s", c$id$orig_h, c$id$resp_h);
}
