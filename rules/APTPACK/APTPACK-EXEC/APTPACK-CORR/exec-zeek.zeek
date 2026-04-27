@load base/protocols/http

event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string)
{
    if ( /\.ps1|\.bat|\.sh|cmd=|exec=|run=/ in to_lower(unescaped_URI) )
    {
        print fmt("APTPACK_EXEC_HTTP uri=%s src=%s dst=%s",
            unescaped_URI, c$id$orig_h, c$id$resp_h);
    }
}
