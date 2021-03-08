# `get`

`get` related commands for **kcr**.

## Usage

```
kcr [-s, --session <name>] [-c, --client <name>] [-r, --raw] get [expansions] [input: data-stream]
```

## Configuration

Bash example configuration:

`~/.bashrc`

``` sh
alias val='kcr get-expansion val'
alias opt='kcr get-expansion opt'
alias reg='kcr get-expansion reg'
```

## Commands

```
kcr get [expansions] [input: data-stream] ⇒ Get states from a client in session
kcr get-expansion <type> <name> [input: data-stream] ⇒ Get expansions from a client in session
```

###### `get`

```
kcr get [expansions] [input: data-stream]
```

Get states from a client in session.

###### `get-expansion`

```
kcr get-expansion <type> <name> [input: data-stream]
```

Get [expansions] from a client in session.

Useful to create aliases.

[Expansions]: https://github.com/mawww/kakoune/blob/master/doc/pages/expansions.asciidoc
