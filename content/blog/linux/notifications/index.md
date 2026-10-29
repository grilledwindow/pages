+++
title = "Simple Notifications for a Tiling WM"
date = 2026-10-29

[taxonomies]
series = ["linux"]
tags = ["all"]
+++

The other day, I was doing a presentation when my Telegram notifications started popping up.
It was embarassing, and something I had not dealt with for the longest time, because there was no real need to.
After that presentation, however, I resolved to not let this happen again.

## Goal
Here is my current desktop configuration:
1. window manager: Herbstluft
2. notification daemon: Dunst
3. status bar: Polybar

The goal is to achieve the following:
1. Keyboard mapping to dismiss notifications and toggle notification state (all/some/off)
2. Notification state reflected with corresponding icon in status bar

## Dunst configuration

### CLI tools
`dunstctl` is a useful CLI tool for sending commands to Dunst.
For example, we can get or set the pause level using `dunstctl get-pause-level` or `dunstctl set-pause-level 100`.
We can also close notifications using the `dunstctl close-all` command.

`notify-send` is another useful tool for testing out our configuration.
`notify-send -u [critical|normal|low] test` sends a notification with the specified urgency level.

### Config file
Dunst uses the `~/.config/dunst/dunstrc` config file, and falls back to `/etc/dunst/dunstrc` if it doesn't exist.
You can copy this file to your `.config` folder and modify it there.

In the config file, I modified the background and frame colours to match my desktop theme.
It also contains critical information needed to toggle between notification states, which is the `override_pause_level`
property under each of the `[urgency_low]`, `[urgency_normal]`, and `[urgency_critical]` sections.

The `override_pause_level` value tells Dunst whether a notification should be displayed or not.
For example, if a notification with urgency "normal", which corresponds to an `override_pause_level` of 30, is sent:
1. It will be displayed if the current pause level is at most 30
2. It will not be displayed if the current pause level is more than 30.

#### Testing pause levels
Let's try to get a notification to show only if its urgency level is critical.
1. Set `override_pause_level` under `[urgency_normal]` to 30 (should be default)
1. Set `override_pause_level` under `[urgency_critical]` to 60 (should be default)
1. Set the pause level: `dunstctl set-pause-level 31`
1. Send the first notification: `notify-send -u normal test` (this shouldn't show)
1. Send the second notification: `notify-send -u critical test` (this should show)

### Scripting
Now that we have tested that the commands work, we can create some scripts to toggle between these notification states.


