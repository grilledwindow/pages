+++
title = "Mapping the Power Key"
date = 2025-10-01

[taxonomies]
series = ["linux"]
tags = ["all"]
+++

On my laptop, the default behaviour of pressing the power key is shutting down the device.
It isn't very nice when I have to set up the desktop from scratch when I accidentally power the laptop off, or when my younger siblings do it on purpose,
so I've decided to put a stop to it.

On my machine, two programs handle the "sleep" state: `acpi` and `elogind`.
Modifying `/etc/acpi/handler.sh` to do nothing when the power button is pressed didn't work,
but updating the `elogind` config worked.

Adding any `.conf` file under `/etc/elogind/logind.conf.d/` should work.
I updated mine to suspend when the power key is pressed and only power off on a long press.

```
[Login]
HandlePowerKey=suspend
HandlePowerKeyLongPress=poweroff
```
`/etc/elogind/logind.conf.d/logind.conf`

No more getting trolled :)

