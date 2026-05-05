# dazpm

`dazpm` is a small zsh package manager for shell packages.

It can install or link packages that expose:

- executable commands from `bin/`
- autoloadable zsh functions from `functions/`
- zsh plugins from `plugins/`
- zsh completions from `completions/zsh/`

The goal is not to replace a system package manager. The goal is to keep zsh tools, plugins, functions and completions isolated under one user-level directory.

## Install

Clone the repository:

```sh
git clone https://github.com/dazui-py/dazpm.git ~/.local/share/dazpm-src
```

Run the init command:

```sh
~/.local/share/dazpm-src/bin/dazpm init
```

Restart zsh or run:

```sh
source ~/.zshrc
```

## Paths

By default, dazpm uses XDG-style paths:

```text
~/.local/share/dazpm
~/.config/dazpm
~/.cache/dazpm
```

Installed package files are linked into:

```text
~/.local/share/dazpm/bin
~/.local/share/dazpm/functions
~/.local/share/dazpm/plugins
~/.local/share/dazpm/completions
```

You can override the data directory with:

```sh
export DAZPM_HOME="$HOME/.local/share/dazpm"
```

## Basic usage

Install a package from GitHub:

```sh
dazpm install user/repo
```

Install a specific branch, tag or ref:

```sh
dazpm install user/repo --ref main
dazpm install user/repo@main
```

Link a local package for development:

```sh
dazpm link ./my-package
```

List packages:

```sh
dazpm list
dazpm list --verbose
```

Update packages:

```sh
dazpm update
dazpm update --git
dazpm update --links
```

Remove a package:

```sh
dazpm remove my-package
```

## Package layout

A package can use the legacy directory layout:

```text
bin/
functions/
plugins/
completions/zsh/
```

Or it can use a `daz.toml` manifest.

## Manifest example

```toml
name = "hello"
version = "0.1.0"
description = "Example dazpm package"
author = "dazui-py"
license = "MIT"

[shell]
supports = ["zsh"]

[install]
bins = ["bin/hello"]
plugins = ["plugins/hello.zsh"]
functions = []
completions = []

[meta]
tags = ["zsh"]
```
