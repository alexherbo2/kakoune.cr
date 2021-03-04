# kakoune.cr

###### [Installation] | [Usage] | [Configuration] | [Commands] | [Extending kcr] | [Writing plugins]

kakoune.cr (kcr) is a command-line tool for [Kakoune].

[Kakoune]: https://kakoune.org

## Dependencies

[Dependencies]: #dependencies

- [Crystal]
- [Shards]
- [jq]

[Crystal]: https://crystal-lang.org
[Shards]: https://github.com/crystal-lang/shards
[jq]: https://stedolan.github.io/jq/

## Installation

[Installation]: #installation

Run the following in your terminal:

``` sh
make install
```

Add the [Kakoune definitions] to your **kakrc**.

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

## Usage

[Usage]: #usage

```
kcr [-s, --session <name>] [-c, --client <name>] [-r, --raw] <command> [arguments]
```

## Configuration

[Configuration]: #configuration

Kakoune example configuration:

`~/.config/kak/kakrc`

``` kak
map -docstring 'New client' global normal <c-t> ': new<ret>'
map -docstring 'New terminal' global normal <c-n> ': connect-terminal<ret>'
map -docstring 'New popup' global normal + ': connect-popup<ret>'
map -docstring 'Open Dolphin' global normal <c-o> ': $ dolphin .<ret>'
map -docstring 'Open files' global normal <c-f> ': + kcr-fzf-files<ret>'
map -docstring 'Open buffers' global normal <c-b> ': + kcr-fzf-buffers<ret>'
map -docstring 'Open files by content' global normal <c-g> ': + kcr-fzf-grep<ret>'
map -docstring 'Open lazygit' global normal <c-l> ': + lazygit<ret>'
```

See [#2] for `'connect' no such command: 'popup'` error.

Bash example configuration:

`~/.bashrc`

``` sh
EDITOR='kcr edit'

alias k='kcr edit'
alias K='kcr-fzf-shell'
alias ks='kcr shell --session'
alias kl='kcr list'
alias a='kcr attach'
alias :='kcr send'
alias :cat='kcr cat --raw'
```

[XDG MIME Applications] example configuration:

`~/.config/mimeapps.list`

```
[Default Applications]
text/plain=kakoune.desktop
```

You can get the MIME type with:

```
file -b -i -L <file>
```

[XDG MIME Applications]: https://wiki.archlinux.org/index.php/XDG_MIME_Applications

## Commands

[Commands]: #commands

**Options**

```
-s, --session <name> ⇒ Session name
-c, --client <name> ⇒ Client name
-r, --raw ⇒ Use raw output
-R, --no-raw ⇒ Do not use raw output
-h, --help ⇒ Show help
```

**Commands**

```
kcr init <name> ⇒ Print functions
kcr init kakoune ⇒ Print Kakoune definitions
kcr init starship ⇒ Print Starship configuration
kcr install <name> ⇒ Install files
kcr install commands ⇒ Install commands
kcr install desktop ⇒ Install desktop application
kcr create [session] ⇒ Create a new session
kcr attach [session] ⇒ Connect to session
kcr list ⇒ List sessions
kcr shell [command] [arguments] ⇒ Start an interactive shell
kcr edit [files] [input: fifo] ⇒ Edit files
kcr open [files] [input: fifo] ⇒ Open files
kcr send <command> [arguments] [input: json-format] ⇒ Send commands to client at session
kcr get [expansions] [input: data-stream] ⇒ Get states from a client in session
kcr cat [buffers] ⇒ Print buffer content
kcr escape [arguments] [input: json-format] ⇒ Escape arguments
kcr help [command] ⇒ Show help
```

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

[Kakoune definitions]: src/init/kakoune.kak

**Example** – **kakrc** configuration:

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

**Commands**

```
connect <command> [arguments] ⇒ Run a command as <command> sh -c {connect} -- [arguments].  Example: connect terminal sh.
run <command> [arguments] ⇒ Run a program in a new session
[$] connect-program <command> [arguments] ⇒ Connect a program
[>] connect-terminal [command] [arguments] ⇒ Connect a terminal
[+] connect-popup [command] [arguments] ⇒ Connect a popup
```

See [#2] for `'connect' no such command: 'popup'` error.

[#2]: https://github.com/alexherbo2/kakoune.cr/issues/2

###### `init starship`

```
kcr init starship
```

Print [🚀][Starship] [Starship configuration].

[Starship]: https://starship.rs
[Starship configuration]: src/init/starship.toml

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

[Shipped commands]: src/commands

###### `install desktop`

```
kcr install desktop
```

Install [desktop application].

[Desktop application]: share/applications/kakoune.desktop

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

```
kcr shell [command] [arguments]
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
kcr send <command> [arguments] [input: json-format]
```

Send commands to client at session.

**Example**

``` sh
kcr send echo tchou
```

**Example** – Format commands:

``` sh
kcr get -- evaluate-commands -draft {} |
kcr get -- execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>' |
jq --slurp |
kcr send
```

###### `get`

```
kcr get [expansions] [input: data-stream]
```

Get states from a client in session.

**Example**

``` sh
kcr get %val{buflist}
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
kcr get %val{bufname} |
kcr get %val{buflist} |
jq --slurp
```

Output:

``` json
[
  [
    "kanto.json"
  ],
  [
    "kanto.json",
    "johto.json"
  ]
]
```

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
[
  "..."
]
```

###### `escape`

```
kcr escape [arguments] [input: json-format]
```

Escape arguments.

**Example**

``` sh
kcr escape -- evaluate-commands -try-client main echo tchou
```

Output:

``` kak
'evaluate-commands' '-try-client' 'main' 'echo' 'tchou'
```

**Example** – Format commands:

``` sh
kcr get -- echo %val{buflist} |
jq --slurp |
kcr escape
```

Output:

``` kak
'echo' 'kanto.json' 'johto.json'
```

###### `help`

```
kcr help [command]
```

Show help.

## Extending kcr

[Extending kcr]: #extending-kcr

Like [Git][Extending Git], kcr allows you to define custom functions and run them as subcommands.

[Extending Git]: https://atlassian.com/git/articles/extending-git

See the [shipped commands] for examples.

## Writing plugins

[Writing plugins]: #writing-plugins

**Example** – Escape arguments:

``` kak
evaluate-commands %sh{
  kcr escape -- echo "maïs'mélange'bientôt"
}
```

**Example** – Async communication (1):

``` kak
$ sh -c %{
  kcr send -- echo tchou
}
```

**Example** – Async communication (2):

``` kak
$ sh -c %{
  kcr send -- echo "$1" and "$2"
} -- %val{session} %val{client}
```

**Example** – Async communication (3):

``` kak
$ sh -c %{
  kcr get -- evaluate-commands -draft {} |
  kcr get -- execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>' |
  jq --slurp |
  kcr send
}
```
