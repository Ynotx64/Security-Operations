@load base/protocols/conn
@load base/frameworks/notice

module SOC;

export {
  redef enum Notice::Type += {
    SOC::Long_Lived_Low_Volume,
    SOC::Rare_External_Admin_Service,
    SOC::Suspicious_Internal_To_External_Web_Response
  };
}

event zeek_init()
  {
  Log::create_stream(Notice::LOG, [$columns=Notice::Info, $path="notice"]);
  }

event connection_state_remove(c: connection)
  {
  if ( c?$duration && c?$orig_bytes && c?$resp_bytes )
    {
    if ( c$duration > 300secs && c$orig_bytes < 5000 && c$resp_bytes < 10000 )
      {
      NOTICE([$note=SOC::Long_Lived_Low_Volume,
              $msg=fmt("Long-lived low-volume connection %s -> %s", c$id$orig_h, c$id$resp_h),
              $sub=fmt("%s:%s -> %s:%s", c$id$orig_h, c$id$orig_p, c$id$resp_h, c$id$resp_p),
              $conn=c]);
      }
    }

  if ( c$id$resp_p in {22/tcp, 3389/tcp, 5985/tcp, 5986/tcp} && Site::is_local_addr(c$id$orig_h) )
    {
    NOTICE([$note=SOC::Rare_External_Admin_Service,
            $msg=fmt("Internal host reached external admin service %s", c$id$resp_h),
            $sub=fmt("%s:%s -> %s:%s", c$id$orig_h, c$id$orig_p, c$id$resp_h, c$id$resp_p),
            $conn=c]);
    }
  }
