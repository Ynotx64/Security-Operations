@load base/protocols/http

event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string)
{
    if ( /whoami|ipconfig|ifconfig|hostname|net user|net group|arp -a|route print/ in to_lower(unescaped_URI) )
        print fmt("APTPACK_DISC_HTTP uri=%s src=%s dst=%s", unescaped_URI, c$id$orig_h, c$id$resp_h);
}
