@load base/protocols/http

event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string)
{
    if ( /startup|autorun|registry|service|scheduledtask|schtask/ in to_lower(unescaped_URI) )
        print fmt("APTPACK_PE_HTTP uri=%s src=%s dst=%s", unescaped_URI, c$id$orig_h, c$id$resp_h);
}
