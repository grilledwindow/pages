+++
title = "Troubleshooting Network Connectivity"
date = 2025-09-11

[taxonomies]
series = ["linux"]
tags = ["all"]
+++

## Slow programs and internet
After trying out `NetworkManager` for the first time, my system coincidentally became sluggish.
Firefox took forever to open, and so did webpages.
Some commands like `mix` took damn long to launch too.

There were two underlying issues:

### hostname
In `/etc/hosts`, I needed to add an entry without the `.localdomain` suffix:
```
127.0.0.1               <hostname>.localdomain      localhost
127.0.1.1               <hostname>                  localhost
```

### DNS
In `/etc/resolv.conf`, I manually set Cloudflare's public DNS resolver to bypass the broken upstream ones:
```
nameserver 1.1.1.1
nameserver 1.0.0.1
```

