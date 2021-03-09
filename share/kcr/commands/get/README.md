# `get`

[`get`] related commands for **kcr**.

[`get`]: https://github.com/alexherbo2/kakoune.cr#get

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
kcr get-expansion <type> <name> ⇒ Get expansions from a client in session
```

###### `get-expansion`

```
kcr get-expansion <type> <name>
```

Get [expansions] from a client in session.

**Note**: This command is only meant to be useful for creating aliases.

[Expansions]: https://github.com/mawww/kakoune/blob/master/doc/pages/expansions.asciidoc
