# Manual

## Usage

```
kcr [-s, --session <name>] [-c, --client <name>] [-r, --raw] <command> [arguments]
```

Open Kakoune, then a connected terminal with `connect terminal` or `connect run alacritty`.
Edit files with [`kcr edit`] and see them being opened in the Kakoune client.
You can set your [`EDITOR`] to [`kcr edit`] and configure your graphical applications to open files with Kakoune.

[`kcr edit`]: #edit
[`EDITOR`]: https://wiki.archlinux.org/index.php/Environment_variables#Default_programs

## Configuration

Add [Kakoune definitions]:

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

[Kakoune definitions]: #init-kakoune

## Options

- `-s`, `--session <name>` ⇒ Session name (Default: [`KAKOUNE_SESSION`])
- `-c`, `--client <name>` ⇒ Client name (Default: [`KAKOUNE_CLIENT`])
- `-r`, `--raw` ⇒ Use raw output
- `-R`, `--no-raw` ⇒ Do not use raw output
- `-d`, `--debug` ⇒ Debug mode (Default: [`KAKOUNE_DEBUG`], **1** for true, **0** for false)
- `-v`, `--version` ⇒ Display version
- `-V`, `--version-notes` ⇒ Display version notes
- `-h`, `--help` ⇒ Show help
- `--` ⇒ Stop handling options
- `-` ⇒ Stop handling options and read stdin

[`KAKOUNE_SESSION`]: #environment-variables
[`KAKOUNE_CLIENT`]: #environment-variables
[`KAKOUNE_DEBUG`]: #environment-variables

## Commands

###### `tldr`

```
kcr tldr
```

Show [usage][`tldr.txt`].

[`tldr.txt`]: ../share/kcr/pages/tldr.txt

###### `prompt`

```
kcr prompt
```

Print prompt.
Returns **1** if no session.

###### `init`

```
kcr init <name>
```

Print functions.

###### `init kakoune`

```
kcr init kakoune
```

Print [Kakoune definitions].

[Kakoune definitions]: ../share/kcr/init/kakoune.kak

**Example** – **kakrc** configuration:

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

### Kakoune commands

###### `connect`

```
connect <command> [arguments]
```

Run a command as `<command> sh -c {connect} -- [arguments]`.

**Example**

``` kak
connect terminal sh
```

###### `run`

```
run <command> [arguments]
```

Run a program in a new session.

--------------------------------------------------------------------------------

###### `init starship`

```
kcr init starship
```

Print [🚀][Starship] [Starship configuration].

[Starship]: https://starship.rs
[Starship configuration]: ../share/kcr/init/starship.toml

###### `install`

```
kcr install <name>
```

Install files.

###### `install commands`

```
kcr install commands
```

Install [commands][Shipped commands].

[Shipped commands]: ../share/kcr/commands

###### `install desktop`

```
kcr install desktop
```

Install [desktop application].

[Desktop application]: ../share/kcr/applications/kcr.desktop

###### `env`

```
kcr env
```

Print Kakoune environment information.

Output example:

``` json
{
  "KAKOUNE_SESSION": "kanto",
  "KAKOUNE_CLIENT": "main",
  "KAKOUNE_DEBUG": "0",
  "KAKOUNE_VERSION": "nightly"
}
```

###### `play`

```
kcr play [file]
```

Start playground with [`example.kak`] by default.

[`example.kak`]: ../share/kcr/init/example.kak

###### `create`

```
kcr create [session]
```

Create a new session.

###### `attach`

```
kcr attach [session]
```

Connect to session.

###### `kill`

```
kcr kill [session]
```

Kill session.

###### `list`

```
kcr list
```

List sessions.

Output example:

``` json
[
  {
    "session": "kanto",
    "client": "main",
    "buffer_name": "pokemon.json",
    "working_directory": "/home/red/kanto"
  }
]
```

###### `shell`

**Options**

- `-d`, `--working-directory <path>` ⇒ Working directory

```
kcr shell [flags] [command] [arguments]
```

Start an interactive shell.

**Example**

``` sh
kcr shell kcr attach
```

###### `edit`

```
kcr edit [files] [input: fifo]
```

Edit files.

###### `open`

```
kcr open [files] [input: fifo]
```

Open files.

###### `send`

```
kcr send <command> [arguments] [input: command]
```

Send commands to client at session.

**Example**

``` sh
kcr send echo pokemon
```

### Multiple commands

It is possible to send multiple commands in a single request with pipes.

``` sh
kcr echo -- echo kanto |
kcr echo - echo johto |
kcr send -
```

### Nested commands

It is possible to create nested commands with `{}` placeholders and pipes.

``` sh
kcr echo -- evaluate-commands -draft {} |
kcr echo - execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>' |
kcr send -
```

The `{}` denotes a block for the next pipe.

In kakspeak:

``` kak
evaluate-commands -draft %{
  execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>'
}
```

###### `echo`

```
kcr echo [arguments]
```

Print arguments.

**Example**

``` sh
kcr echo -- echo pokemon
```

Output:

``` json
["echo", "pokemon"]
```

**Example** – Streaming data:

``` sh
kcr echo -- evaluate-commands -draft {} |
kcr echo - execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>'
```

Output:

``` json
["evaluate-commands", "-draft", "{}"]
["execute-keys", "<a-i>b", "i<backspace><esc>", "a<del><esc>"]
```

Add [`kcr send -`] for sending the nested command.

[`kcr send -`]: #send

###### `get`

**Options**

- `-V`, `--value <name>` ⇒ Value name
- `-O`, `--option <name>` ⇒ Option name
- `-R`, `--register <name>` ⇒ Register name
- `-S`, `--shell <command>` ⇒ Shell command

```
kcr get [flags] [expansions]
```

Get [states][expansions] from a client in session.

[Expansions]: https://github.com/mawww/kakoune/blob/master/doc/pages/expansions.asciidoc

**Example**

``` sh
kcr get --value buflist
```

Output:

``` json
[
  "kanto.json",
  "johto.json"
]
```

**Example** – Streaming data:

``` sh
kcr get --option pokemon |
kcr get --option regions -
```

Output:

``` json
[
  "Bulbasaur",
  "Charmander",
  "Squirtle"
]
[
  "Kanto",
  "Johto"
]
```

Add `jq --slurp` to read the entire input stream into a large array.

###### `cat`

```
kcr cat [buffers]
```

Print buffer content.

**Example**

``` sh
kcr cat
```

Output:

``` json
["buffer content..."]
```

Use the [`--raw`] flag for raw output:

``` sh
kcr cat --raw
```

[`--raw`]: #options

###### `pipe`

```
kcr pipe <program> [arguments] [input: selections]
```

Pipe selections to a program.

**Example** – Sort selections:

``` sh
kcr pipe jq sort
```

You can also finalize with a pipe:

``` sh
kcr get --value selections | jq sort | kcr pipe -
```

###### `escape`

```
kcr escape [arguments] [input: arguments]
```

Escape arguments.

**Example**

``` sh
kcr escape -- evaluate-commands -client main echo pokemon
```

Output:

``` kak
'evaluate-commands' '-client' 'main' 'echo' 'pokemon'
```

See also [Multiple commands] and [Nested commands].

[Multiple commands]: #multiple-commands
[Nested commands]: #nested-commands

###### `help`

```
kcr help [command]
```

Show help.

###### `version`

```
kcr version
```

Display version.

## Extending the command-line interface

Like [Git][Extending Git], kcr allows you to define custom functions and run them as subcommands.

[Extending Git]: https://atlassian.com/git/articles/extending-git

See the [shipped commands] for examples.

[Shipped commands]: ../share/kcr/commands

## Environment variables

- `KAKOUNE_SESSION`: Kakoune session
- `KAKOUNE_CLIENT`: Kakoune client
- `KAKOUNE_DEBUG`: Kakoune debug flag (**1** for true, **0** for false)

## Troubleshooting

Use the [`-d`] | [`--debug`] flag or set [`KAKOUNE_DEBUG`] to write a log message in the terminal and in Kakoune if available (see the `*debug*` buffer).

[`-d`]: #options
[`--debug`]: #options
[`KAKOUNE_DEBUG`]: #environment-variables

**Example** – with command-line flag:

``` sh
kcr --debug send -- echo pokemon
```

**Example** – with environment variable:

``` sh
export KAKOUNE_DEBUG=1
kcr send -- echo pokemon
```

Output:

``` json
{
  "session": "kanto",
  "client": "main",
  "constructor": [["echo", "pokemon"]],
  "command": "'echo' 'pokemon'"
}
```
