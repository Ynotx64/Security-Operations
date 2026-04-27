@load base/protocols/http

event http_header(c: connection, is_orig: bool, name: string, value: string)
{
    if ( is_orig && to_lower(name) == "user-agent" )
        return;
}
