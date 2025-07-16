+++
title = "Useful Commands I'll Probably Forget"
date = 2025-07-16

[taxonomies]
series = []
tags = ["all"]
+++

I regularly use the command line, and yet I'm googling unfamiliar commands more often than not...
So I decided to keep them all in one place here.

#### Storage utilities
`du -hd <depth> [target] | sort -h` - get sorted disk usage (to see where space is being used the most) \

#### Archive
`tar xvzf <archive.tar.gz>` - unarchive `.tar.gz`
```
-x --extract = extract files from an archive
-v, --verbose = verbosely list files processed
-z, --gzip = gzipped files eg. for tar.gz packages
-f, --file ARCHIVE = use archive file or device ARCHIVE
```

#### VoidLinux
`xbps-query -Rs <package>` - query all packages \
`xbps-query -s <package>` - query installed packages \
`sudo ln -s /etc/sv/<service> /var/service/` - enable `service` \
`sudo vkpurge rm all` - remove unused kernel modules to free space

