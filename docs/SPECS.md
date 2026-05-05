# dazpm Specification

`dazpm` is a shell package manager focused on zsh packages.

It installs and manages shell utilities such as:

- executable commands
- zsh plugins
- zsh autoload functions
- zsh completions

The current implementation is written in zsh. A future implementation may move the core logic to Go, while keeping the zsh loader.

---

## Goals

`dazpm` should make it easy to install, inspect, validate, update and develop shell packages.

Main goals:

- support zsh-first packages
- keep `.zshrc` clean
- support local package development
- support Git-based packages
- support package metadata through `daz.toml`
- provide predictable command behavior before rewriting the core in Go

---

## Non-goals for now

The current version does not aim to be:

- a full TOML implementation
- a full shell framework
- a replacement for zsh plugin managers yet
- a secure sandbox for untrusted shell code
- a binary package manager

Shell packages can execute arbitrary code when sourced. Users should only install packages they trust.

---

## Directory layout

Installed data lives under:

```txt
$XDG_DATA_HOME/dazpm
