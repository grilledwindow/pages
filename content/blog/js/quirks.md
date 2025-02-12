+++
title = "Quirks with Web JS"
date = 2025-02-13

[taxonomies]
series = []
tags = ["all", "web", "js"]
+++

Here I document all the quirks I've encountered while writing Javascript code for web projects.

## Mouse events
1. `mouseenter` doesn't bubble like `mouseover`
2. `event.clientX` and `event.clientY` are unreliable and inconsistent for obtaining cursor position.
Instead, use `{ top, left }` from `event.getBoudingClientRect()`

I tried adding a popup element on hover but its positioning was inconsistent.
The cursor entering from the top vs from the bottom resulted in different positions for the popup.
affected
