+++
title = "FourX: Settng Up Elixir and Neovim"
date = 2025-03-25

[taxonomies]
series = ["fourx"]
tags = ["all", "elixir", "neovim"]
+++

## Introduction
Lately, I've been exploring web technologies and bought a new camera.
Naturally I thought of revisiting an old web project, `dorb`, that helped me learn some WASM.
It's a website that allows users to upload multiple photos, add frames to them, and download the results as a zip file.
However, it was slow and I wasn't happy with the results.

Enter Phoenix LiveView: a framework I chanced upon - it uses web sockets, and leverages on Elixir's concurrency and fault-tolerance.
I thought, "Wow, this is exactly what I need!"
`dorb`'s successor will be "Bordro", whose name is inspired by my first camera - the Sigma DP2 Quattro.

As much as I wish to jump straight into Bordro, I'm taking it slow to familiarise myself with new concepts in Elixir, especially those about concurrency and functional programming.
Hence, I'm kicking off my Elixir journey with FourX: the Connect 4 game with a twist!

Join me as I embark on this exciting adventure!

## Setup
Let's start off with a not-so-exciting part: the setup. I thought it'd be as trivial as just installing `elixir` and `erlang`, but I couldn't be further from the truth.

### Neovim
Setting up the LSP was pretty straightforward, I used `nextls` because `lexical` was giving me a lot of trouble.
Unfortunately, I took longer than I'd have liked to get Treesitters's syntax highlighting working.
I had to run `:TSEnable highlight` manually every time I opened a file.
Upon running `:TSModuleInfo`, I realised that Treesitter wasn't enabled for all of the file types.
The fix was moving `opts` to the `config` function:

```lua
config = function()
    require("nvim-treesitter.configs").setup({
        ensure_installed = { ..., "elixir", "erlang" },
        ...
    })
end
```
`.config/nvim/lua/plugins/treesitter.lua`

### mise
I decided to try {{ link(label="mise", link="https://github.com/jdx/mise") }} because Void's version of `erlang` wasn't up to date.
However, I was faced with errors right off the bat.
`automake` and `autoconf` were missing and caused errors which were fixed simply by installing the packages.
I was told no `curses` library was available, but `xbps-query -Rs curses` showed that I had `ncurses` installed,
but apparently not `ncurses-devel`... Okay, this took a while but it was resolved easily.

### WxWidgets
`mix` and `iex` ran just fine, but I couldn't run the really cool process monitor `:observer`!
This was where things got messy.

```elixir
def application do
[
    extra_applications: [:logger, :observer, :wx],
    mod: {Fourx.Application, []}
]
end
```
`mix.exs`

Adding `:observer` and `:wx`, the GUI library that's used spawned a few errors.
`WxWidgets` wasn't configured properly.
`mise` uses `kerl` to build `erlang`, and it couldn't find `wx-config` even though I had the relevant packages installed, because they were named `wx-config-gtk3` on my system.
Using a simpe alias didn't work, I had to set the environment variable:

`KERL_CONFIGURE_OPTIONS="--enable-wx --with-wx-config=/bin/wx-config-gtk3"`

This magic line saved me from my misery.

### Disabled Features
A few other features were disabled during the installation because of missing packages again.
Just like the `ncurses` error, I had to install the relevant `*-devel` packages for `openssl`, `libepoxy` (OpenGL), `unixodbc`, and `WxWidgets` 

## Conclusion
The setup took a while, but now I'm all ready to *actually* start work, haha!

