@load base/protocols/http

event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if ( is_orig && to_lower(name) == "host" )
        print fmt("APTPACK_CA_HOST_HEADER src=%s dst=%s host=%s", c$id$orig_h, c$id$resp_h, value);
}
