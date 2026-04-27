@load base/protocols/http

event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if ( is_orig && /content-range|transfer-encoding|content-encoding/i in name )
        print fmt("APTPACK_STAGE_HEADER src=%s dst=%s name=%s value=%s", c$id$orig_h, c$id$resp_h, name, value);
}
