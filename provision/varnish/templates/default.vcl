# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#
import std;
backend default {
  .host = "default-do";
  .port = "8080";
  .connect_timeout = 3.0s;
  .first_byte_timeout = 45s;
  .between_bytes_timeout = 30s;
}

backend wordpress {
  .host = "wordpress-do";
  .port = "8080";
  .connect_timeout = 3.0s;
  .first_byte_timeout = 45s;
  .between_bytes_timeout = 30s;
}

backend mt {
  .host = "mt-do";
  .port = "8080";
  .connect_timeout = 3.0s;
  .first_byte_timeout = 45s;
  .between_bytes_timeout = 30s;
}

backend drupal {
  .host = "drupal-do";
  .port = "8080";
  .connect_timeout = 3.0s;
  .first_byte_timeout = 45s;
  .between_bytes_timeout = 30s;
}


backend {{ host_tag }} {
  .host = "{{ host_name }}";
  .port = "80";
  .connect_timeout = 3.0s;
  .first_byte_timeout = 45s;
  .between_bytes_timeout = 30s;
}

acl purge {
  "localhost";
  "127.0.0.1"/24;
}

# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
sub vcl_recv {

  # Default backend is set to VM1
   set req.backend = default;

   std.syslog(0, "[vcl_recv - req.host]" + req.http.host);


   if (req.http.host == "{{ host_name }}:6081" || req.http.host == "{{ host_name }}:{{ listen_port }}" || req.http.host == "{{ host_name }}") {
       set req.backend = {{ host_tag }};
   }

   if (req.http.host == "wordpress-do" || req.http.host == "wordpress-do:8080") {
       set req.backend = wordpress;
   }
   if (req.http.host == "drupal-do" || req.http.host == "drupal-do:8080") {
       set req.backend = drupal;
   }
   if (req.http.host == "mt-do" || req.http.host == "mt-do:8080") {
       set req.backend = mt;
   }

  #set req.http.Host="mdcms.site-test.jp";
  #set req.http.Host="www.biyougeka.com";
  if (req.request == "GET" && req.url ~ "^/varnishcheck$") {
    error 200 "Varnish is Ready";
  }

  std.syslog(0, "[vcl_recv - backend set to: ]" + req.backend);

  # Redirect all cdn requests
  # if any

  # Allow the backend to serve up stale content if it is responding slowly.
  if (!req.backend.healthy) {
    # Use anonymous, cached pages if all backends are down.
    unset req.http.Cookie;
    if (req.http.X-Forwarded-Proto == "https") {
      set req.http.X-Forwarded-Proto = "http";
    }
    set req.grace = 30m;
  } else {
    set req.grace = 15s;
  }

  # Allow PURGE from localhost and 192.168.0.0/24
  if (req.request == "PURGE") {
    if (!client.ip ~ purge) {
      error 405 "Not allowed.";
    }
    return (lookup);
  }

  # Do not cache these paths.
  if (req.url ~ "^/dashboard/.*$" ||
      req.url ~ "^/login.*$") {
        return (pass);
  }

  # Handle compression correctly. Different browsers send different
  # "Accept-Encoding" headers, even though they mostly all support the same
  # compression mechanisms. By consolidating these compression headers into
  # a consistent format, we can reduce the size of the cache and get more hits.=
  # @see: http:// varnish.projects.linpro.no/wiki/FAQ/Compression
  if (req.http.Accept-Encoding) {
    if (req.http.Accept-Encoding ~ "gzip") {
      # If the browser supports it, we'll use gzip.
      set req.http.Accept-Encoding = "gzip";
    }
    else if (req.http.Accept-Encoding ~ "deflate") {
      # Next, try deflate if it is supported.
      set req.http.Accept-Encoding = "deflate";
    }
    else {
      # Unknown algorithm. Remove it and send unencoded.
      unset req.http.Accept-Encoding;
    }
  }

  # Always cache the following file types for all users.
  if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js)(\?[a-z0-9]+)?$") {
    unset req.http.Cookie;
  }

  # Remove all cookies that Drupal doesn't need to know about. ANY remaining
  # cookie will cause the request to pass-through to a backend. For the most part
  # we always set the NO_CACHE cookie after any POST request, disabling the
  # Varnish cache temporarily. The session cookie allows all authenticated users
  # to pass through as long as they're logged in.
  #
  # 1. Append a semi-colon to the front of the cookie string.
  # 2. Remove all spaces that appear after semi-colons.
  # 3. Match the cookies we want to keep, adding the space we removed
  #    previously, back. (\1) is first matching group in the regsuball.
  # 4. Remove all other cookies, identifying them by the fact that they have
  #    no space after the preceding semi-colon.
  # 5. Remove all spaces and semi-colons from the beginning and end of the
  #    cookie string.
  if (req.http.Cookie) {

    #general cookie setting
    set req.http.Cookie = ";" + req.http.Cookie;
    set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", ""); # Google Analytics
    set req.http.Cookie = regsuball(req.http.Cookie, "_ga=[^;]+(; )?", ""); # Old Google Analytics
    set req.http.Cookie = regsuball(req.http.Cookie, "__u.+=[^;]+(; )?", ""); # additional cookies like share this

    #concrete5 & mediclude
    if(req.http.Cookie ~ "(^|;\s*)(^ccmUserHash)") {
        unset req.http.Cookie;
        std.syslog(0, "[Unset!]");
    }
    set req.http.Cookie = regsuball(req.http.Cookie, "IID=[^;]+(; )?", ""); # c5
    set req.http.Cookie = regsuball(req.http.Cookie, "CONCRETE5=[^;]+(; )?", ""); # c5
    set req.http.Cookie = regsuball(req.http.Cookie, "VA_CONV_ID=[^;]+(; )?", ""); # c5
    set req.http.Cookie = regsuball(req.http.Cookie, "ac=[^;]+(; )?", ""); # ad
    set req.http.Cookie = regsuball(req.http.Cookie, "admuk[a-z0-9]+=[^;]+(; )?", ""); # ad
    set req.http.Cookie = regsuball(req.http.Cookie, "uk[a-z0-9]+=[^;]+(; )?", ""); # ad
    set req.http.Cookie = regsuball(req.http.Cookie, "_rt\.uid=[^;]+(; )?", ""); # mediclude ad
    set req.http.Cookie = regsuball(req.http.Cookie, "_rt\.xd=[^;]+(; )?", ""); # mediclude ad

    #For WordPress Cookie
        if (req.url ~ "/wp-(login|admin|cron)") {
            return (pass);
        }
        set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-1=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-time-1=[^;]+(; )?", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");
        if (req.url ~ "wp-content/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
            unset req.http.cookie;
        }
        if (req.url ~ "/wp-content/uploads/") {
            return (pass);
        }
        if (req.http.Cookie ~ "wordpress_" || req.http.Cookie ~ "comment_") {
            std.syslog(0, req.url + " is passed because client is logged in user.");
            return (pass);
        }

    #cookie data cleansing
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
    #error 503 "Cookie:" + req.http.Cookie;
    if (req.http.Cookie == "") {
      # If there are no remaining cookies, remove the cookie header. If there
      # aren't any cookie headers, Varnish's default behavior will be to cache
      # the page.
      unset req.http.Cookie;
    } else {
      # If there is any cookies left (a session or NO_CACHE cookie), do not
      # cache the page. Pass it on to Apache directly.
      std.syslog(0, "[recv - cookie & UA]" + req.http.Cookie + " " + req.http.User-Agent);
      return (pass);
    }
  }

     if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For =
                req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
     }
     if (req.request != "GET" &&
       req.request != "HEAD" &&
       req.request != "PUT" &&
       req.request != "POST" &&
       req.request != "TRACE" &&
       req.request != "OPTIONS" &&
       req.request != "DELETE") {
         /* Non-RFC2616 or CONNECT which is weird. */
         return (pipe);
     }
     if (req.request != "GET" && req.request != "HEAD") {
         /* We only deal with GET and HEAD by default */
         std.syslog(0, "[recv - not GET and HEAD]");
         return (pass);
     }
     if (req.http.Authorization || req.http.Cookie) {
         /* Not cacheable by default */
         std.syslog(0, "[recv - cookie or authorization]" + " passed");
         return (pass);
     }
     return (lookup);
}

sub vcl_pipe {
     # Note that only the first request to the backend will have
     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
     # have it set for all requests, make sure to have:
     # set bereq.http.connection = "close";
     # here.  It is not set by default as it might break some broken web
     # applications, like IIS with NTLM authentication.
     return (pipe);
}

sub vcl_pass {
    return (pass);
}

sub vcl_hash {
     hash_data(req.url);
     if (req.http.host) {
         hash_data(req.http.host);
     } else {
         hash_data(server.ip);
     }
     #error 503 "hash?";
     return (hash);
}


sub vcl_hit {
    return (deliver);
}


sub vcl_miss {
     return (fetch);
}


# sub vcl_fetch {
#     if (beresp.ttl <= 0s ||
#         beresp.http.Set-Cookie ||
#         beresp.http.Vary == "*") {
#               /*
#                * Mark as "Hit-For-Pass" for the next 2 minutes
#                */
#               set beresp.ttl = 120 s;
#               return (hit_for_pass);
#     }
#     return (deliver);
# }
sub vcl_fetch {
  unset beresp.http.set-cookie;
  if (beresp.status == 404 || beresp.status == 301 || beresp.status == 500) {
    set beresp.ttl = 10m;
  }

  #remove set cookie if requested is not html ones.
  if (req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
    unset beresp.http.set-cookie;
  }

   if (beresp.http.Set-Cookie ~ "(^|;\s*)(x-redirect)=1*") {
       std.syslog(0, "[fetch_x-redirect]" + req.http.Cookie);
       #return (hit_for_pass);
   } else {
       #std.syslog(0, "[fetch_noredirect]" + beresp.http.Set-Cookie);
   }
   if (beresp.ttl < 180s) {
      set beresp.ttl = 180s;
   }
   #set beresp.grace = 6h;

   #follow location header and cache it
   if ( beresp.status == 301 || beresp.status == 302) {
      set req.http.X-Redirected-Orig = beresp.http.Location;
      set req.http.host = regsub(regsub(beresp.http.Location,"^http://",""),"^([^/]+)/.*$","\1");
      set req.url = regsub(beresp.http.Location,"^http://[^/]+/(.*)$","/\1");
      set req.http.X-Redirected-To = "http://" + req.http.host + req.url;
      std.syslog(0,"restarted");
      return (restart);
   }
   return (deliver);
}

 sub vcl_deliver {
     return (deliver);
 }

sub vcl_error {
    if((obj.status >= 100 && obj.status < 200) || obj.status == 204 || obj.status == 304){
        return (deliver);
    }
}

 sub vcl_init {
        return (ok);
 }

 sub vcl_fini {
        return (ok);
 }
