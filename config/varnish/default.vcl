vcl 4.1;

backend tileserv {
    .host = "pg-tileserv";
    .port = "7800";
}

backend api {
    .host = "backend";
    .port = "8000";
}

backend nginx {
    .host = "nginx";
    .port = "80";
}

backend frontend {
    .host = "frontend";
    .port = "80";
}


sub vcl_deliver {
  # Display hit/miss info
  if (obj.hits > 0) {
    set resp.http.V-Cache = "HIT";
  }
  else {
    set resp.http.V-Cache = "MISS";
  }
}

sub vcl_backend_response {
#  unset beresp.http.set-cookie;
  if (beresp.status == 200) {
    unset beresp.http.Cache-Control;
    set beresp.http.Cache-Control = "public; max-age=30";
    set beresp.ttl = 30s;
  }
  set beresp.http.Served-By = beresp.backend.name;
  set beresp.http.V-Cache-TTL = beresp.ttl;
  set beresp.http.V-Cache-Grace = beresp.grace;
}

sub vcl_recv {
   if (req.url ~ "^/sagui") {
    #unset req.http.cookie;
    set req.backend_hint = frontend;
   }
   if (req.url ~ "^/tiles/") {
    unset req.http.cookie;
    set req.backend_hint = tileserv;
   }
   if (req.url ~ "^/backend_static/") {
    set req.backend_hint = nginx;
   }
   if (req.url ~ "^/api/" || req.url ~ "^/admin/") {
    unset req.http.cookie;
    set req.backend_hint = api;
   }
}
