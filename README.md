# kakoune.cr

###### [Installation] | [Usage] | [Configuration] | [Commands] | [Extending kcr] | [Writing plugins] | [Troubleshooting]

kakoune.cr (kcr) is a command-line tool for [Kakoune].

It is a great companion to work with projects, multiple files and headless sessions.

[Kakoune]: https://kakoune.org

[![kakoune.cr](https://img.youtube.com/vi_webp/FUndUED1O7Q/maxresdefault.webp)](https://youtube.com/playlist?list=PLdr-HcjEDx_klQYqXIAmBpywj7ggsDPer "YouTube – kakoune.cr")
[![YouTube Play Button](https://www.iconfinder.com/icons/317714/download/png/16)](https://youtube.com/playlist?list=PLdr-HcjEDx_klQYqXIAmBpywj7ggsDPer) · [kakoune.cr](https://youtube.com/playlist?list=PLdr-HcjEDx_klQYqXIAmBpywj7ggsDPer)

###### What can I do?

- Connect applications to Kakoune.
- Control Kakoune from the command-line.
- Manage sessions.
- Write plugins.

Give it a spin: [`kcr tldr`][`tldr`] & [`kcr play`][`play`]

See what’s new with [`kcr --version-notes`][`--version-notes`] or read the [changelog].

[Changelog]: CHANGELOG.md

###### How does it work?

kakoune.cr is based around the concept of contexts, which can be set via the [`--session`] and [`--client`] options.

For example, the following command will open the file in the main client of the Kanto session.

``` sh
kcr edit --session=kanto --client=main pokemon.json
```

Most of the time, you don’t need to specify them.
[`connect`] will forward [`$KAKOUNE_SESSION`] and [`$KAKOUNE_CLIENT`] environment variables,
which will be used by [`kcr`] to run commands in the specified context.

**Example** – Connect a terminal:

``` kak
connect terminal
```

**Example** – Connect a program:

``` kak
connect run alacritty
```

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

### Nightly builds

Download the [Nightly builds].

[Nightly builds]: https://github.com/alexherbo2/kakoune.cr/releases/nightly

### Build from source

Run the following in your terminal:

``` sh
make install
```

### Kakoune definitions

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

[`kcr`]: #usage

Open Kakoune, then a connected terminal with `connect terminal` or `connect run alacritty`.
Edit files with [`kcr edit`][`edit`] and see them being opened in the Kakoune client.
You can set your [`$EDITOR`] to [`kcr edit`][`edit`] and configure your graphical applications to open files with Kakoune.

[`$EDITOR`]: https://wiki.archlinux.org/index.php/Environment_variables#Default_programs

###### Workflows

kakoune.cr has a lot of commands and options, but you only need to remember a few things to be productive.

Terminal:

- `k` ⇒ Open files.
- `K[K]` ⇒ Open shell or program.
- `ks` ⇒ Create session.
- `kl` ⇒ List sessions.
- `a` ⇒ Attach session.

Kakoune:

- <kbd>Control</kbd> + <kbd>o</kbd> ⇒ Open files with GUI program.
- <kbd>Control</kbd> + <kbd>e</kbd> ⇒ Open files with TUI program.
- <kbd>Control</kbd> + <kbd>f</kbd> ⇒ Open files with fuzzy finder.
- <kbd>Control</kbd> + <kbd>b</kbd> ⇒ Open buffers with fuzzy finder.

See [Configuration] for aliases and mappings.

## Configuration

[Configuration]: #configuration

Kakoune example configuration:

`~/.config/kak/kakrc`

``` kak
# Documentation ────────────────────────────────────────────────────────────────

# kcr-open-doc ⇒ open kakoune.cr documentation
# kcr-open-kakrc ⇒ open kakoune.cr kakrc

# Preamble ─────────────────────────────────────────────────────────────────────

try %sh{
  kcr init kakoune
  kak-lsp --kakoune --session "$kak_session"
}

try lsp-enable

# Adapt the location
source /path/to/alacritty.kak
source /path/to/tmux.kak

# Kakoune support
# https://github.com/mawww/kakoune/tree/master/rc
try %{
  source-runtime rc/filetype/asciidoc.kak
  source-runtime rc/filetype/c-family.kak
  source-runtime rc/filetype/crystal.kak
  source-runtime rc/filetype/git.kak
  source-runtime rc/filetype/kakrc.kak
  source-runtime rc/filetype/makefile.kak
  source-runtime rc/filetype/markdown.kak
  source-runtime rc/filetype/sh.kak
  source-runtime rc/tools/comment.kak
  source-runtime rc/tools/doc.kak
  source-runtime rc/tools/git.kak
  source-runtime rc/tools/grep.kak
  source-runtime rc/tools/make.kak
  source-runtime rc/tools/man.kak
  source-runtime rc/windowing/new-client.kak
}

# Options ──────────────────────────────────────────────────────────────────────

# UI options
set-option global startup_info_version 20211231
set-option global ui_options terminal_assistant=none
delete-scratch-message

# Color scheme
# Dracula – https://draculatheme.com/kakoune
source-config colors/dracula.kak

# Status line
add-cursor-character-unicode-expansion
set-option global modelinefmt '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - U+%opt{cursor_character_unicode} - %val{client}@%val{session}'

# Indentation
set-indent global 2
enable-detect-indent
enable-auto-indent

# Auto-pairing of characters
enable-auto-pairs

# Disable indentation hooks
set-option global disabled_hooks '(?!auto)(?!detect)\K(.+)-(trim-indent|insert|indent)'

# Highlighters
add-highlighter -override global/number-lines number-lines
add-highlighter -override global/show-matching show-matching

# Show selections
show-selected-text

# Show whitespaces
add-highlighter -override global/show-whitespaces show-whitespaces
add-highlighter -override global/show-trailing-whitespaces regex '\h+$' '0:red+f'
add-highlighter -override global/show-non-breaking-spaces regex ' +' '0:red+f'

# Show characters
add-highlighter -override global/show-unicode-2013 regex '–' '0:green+f'
add-highlighter -override global/show-unicode-2014 regex '—' '0:green+bf'
add-highlighter -override global/show-math-symbols regex '[−×]' '0:cyan+f'
add-highlighter -override global/show-limit regex '(?S)^.{79}[=-─┈]\K\n' '0:green+f'

# Save buffer
make-directory-on-save

# Clipboard
synchronize-clipboard
synchronize-buffer-directory-name-with-register d

# Tools
set-option global makecmd 'make -j 8'
set-option global grepcmd 'rg --column'

# Windowing
alacritty-integration-enable
tmux-integration-enable

# Optional
# If you don’t have a popup command
remove-hooks global terminal-integration
hook -group terminal-integration global ModuleLoaded wayland %{ alias global popup wayland-terminal }
hook -group terminal-integration global ModuleLoaded x11 %{ alias global popup x11-terminal }

# Mappings ─────────────────────────────────────────────────────────────────────

# Normal mode ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

# Hot reloading
map -docstring 'reload kakrc' global normal <F5> ':source-kakrc; echo reloaded kakrc<ret>'

# Editing
map -docstring 'save' global normal <c-s> ':write; echo saved<ret>'
map -docstring 'quit' global normal <c-q> ':quit<ret>'
map -docstring 'close buffer' global normal <c-w> ':delete-buffer<ret>'
map -docstring 'last buffer' global normal <c-a> ga

# Search
map -docstring 'search (replace)' global normal f ':search-replace<ret>'
map -docstring 'search (extend)' global normal F ':search-extend<ret>'
map -docstring 'search (append)' global normal <a-f> ':search-append<ret>'

# Selection primitives
map -docstring 'enter insert mode with main selection' global normal ^ ':enter-insert-mode-with-main-selection<ret>'
map -docstring 'select next word' global normal w ':select-next-word<ret>'
map -docstring 'surround' global normal q ':surround<ret>'
map -docstring 'select objects' global normal S ':select-objects<ret>'
map -docstring 'select all occurrences of current selection' global normal <a-percent> ':select-highlights<ret>'
map -docstring 'move line down' global normal <down> ':move-lines-down<ret>'
map -docstring 'move line up' global normal <up> ':move-lines-up<ret>'

# Tools
map -docstring 'math' global normal = ':math<ret>'

# Windowing
map -docstring 'client' global normal <c-t> ':new<ret>'
map -docstring 'terminal' global normal <c-n> ':connect-terminal<ret>'
map -docstring 'file explorer' global normal <c-e> ':connect panel sidetree --select %val{buffile}<ret>'
map -docstring 'file picker' global normal <c-f> ':connect popup kcr fzf files<ret>'
map -docstring 'buffer picker' global normal <c-b> ':connect popup kcr fzf buffers<ret>'
map -docstring 'grep picker' global normal <c-g> ':connect popup kcr fzf grep<ret>'
map -docstring 'git' global normal <c-l> ':connect popup gitui<ret>'

# Insert mode ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

map -docstring 'indent' global insert <tab> '<a-;><a-gt>'
map -docstring 'deindent' global insert <s-tab> '<a-;><lt>'

# View mode ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

map -docstring 'view mode' global normal v V
map -docstring 'show palette' global view p '<esc>:show-palette<ret>'
```

Bash example configuration:

`~/.bashrc`

``` sh
alias k='kcr edit'
alias K='kcr-fzf-shell'
alias KK='K --working-directory .'
alias ks='kcr shell --session'
alias kl='kcr list'
alias a='kcr attach'
```

[Environment variables] example configuration:

`~/.profile`

``` sh
export EDITOR='kcr edit'
export FZF_DEFAULT_OPTS='--multi --layout=reverse --preview-window=down:60%'
```

[Environment variables]: https://wiki.archlinux.org/index.php/Environment_variables

[XDG MIME Applications] example configuration:

`~/.config/mimeapps.list`

``` ini
[Default Applications]
text/plain=kcr.desktop
```

You can get the MIME type with:

```
file -b -i -L <file>
```

[XDG MIME Applications]: https://wiki.archlinux.org/index.php/XDG_MIME_Applications

Here is a list of [common MIME types], with all types I have personally experimented:

`~/.config/mimeapps.list`

``` ini
[Default Applications]
application/csv=kcr.desktop
application/json=kcr.desktop
application/postscript=kcr.desktop
text/html=kcr.desktop
text/plain=kcr.desktop
text/troff=kcr.desktop
text/x-c++=kcr.desktop
text/x-c=kcr.desktop
text/x-java=kcr.desktop
text/x-lisp=kcr.desktop
text/x-makefile=kcr.desktop
text/xml=kcr.desktop
text/x-ruby=kcr.desktop
text/x-script.python=kcr.desktop
text/x-shellscript=kcr.desktop
```

[Common MIME types]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types

## Commands

###### [`tldr`] | [`doc`] | [`prompt`] | [`init`] | [`init kakoune`] | [`init starship`] | [`install`] | [`install commands`] | [`install desktop`] | [`env`] | [`play`] | [`create`] | [`attach`] | [`kill`] | [`list`] | [`shell`] | [`edit`] | [`open`] | [`send`] | [`echo`] | [`get`] | [`cat`] | [`pipe`] | [`escape`] | [`help`]

[Commands]: #commands

**Options**

```
-s, --session <name> ⇒ Session name (Default: $KAKOUNE_SESSION)
-c, --client <name> ⇒ Client name (Default: $KAKOUNE_CLIENT)
-r, --raw ⇒ Use raw output
-R, --no-raw ⇒ Do not use raw output
-d, --debug ⇒ Debug mode (Default: $KAKOUNE_DEBUG, 1 for true, 0 for false)
-v, --version ⇒ Display version
-V, --version-notes ⇒ Display version notes
-h, --help ⇒ Show help
-- ⇒ Stop handling options
- ⇒ Stop handling options and read stdin
```

[`--session`]: #commands
[`--client`]: #commands
[`-d`]: #commands
[`--debug`]: #commands
[`-V`]: #commands
[`--version-notes`]: #commands

[`$KAKOUNE_SESSION`]: #commands
[`$KAKOUNE_CLIENT`]: #commands
[`$KAKOUNE_DEBUG`]: #commands

**Commands**

```
kcr tldr ⇒ Show usage
kcr doc ⇒ Display documentation
kcr prompt ⇒ Print prompt
kcr init <name> ⇒ Print functions
kcr init kakoune ⇒ Print Kakoune definitions
kcr init starship ⇒ Print Starship configuration
kcr install <name> ⇒ Install files
kcr install commands ⇒ Install commands
kcr install desktop ⇒ Install desktop application
kcr env ⇒ Print Kakoune environment information
kcr play [file] ⇒ Start playground
kcr create [session] ⇒ Create a new session
kcr attach [session] ⇒ Connect to session
kcr kill [session] ⇒ Kill session
kcr list ⇒ List sessions
kcr shell [-d, --working-directory <path>] [command] [arguments] ⇒ Start an interactive shell
kcr edit [files] [input: fifo] ⇒ Edit files
kcr open [files] [input: fifo] ⇒ Open files
kcr send <command> [arguments] [input: json-format] ⇒ Send commands to client at session
kcr echo [arguments] [input: data-stream] ⇒ Print arguments
kcr get [-V, --value <name>] [-O, --option <name>] [-R, --register <name>] [-S, --shell <command>] [expansions] [input: data-stream] ⇒ Get states from a client in session
kcr cat [buffers] ⇒ Print buffer content
kcr pipe <program> [arguments] [input: json-selections] ⇒ Pipe selections to a program
kcr escape [arguments] [input: json-format] ⇒ Escape arguments
kcr help [command] ⇒ Show help
```

###### `tldr`

[`tldr`]: #tldr

```
kcr tldr
```

Show [usage][`tldr.txt`].

[`tldr.txt`]: share/kcr/pages/tldr.txt

###### `doc`

[`doc`]: #doc

```
kcr doc
```

Display [documentation][pages].

[Pages]: share/kcr/pages

###### `prompt`

[`prompt`]: #prompt

```
kcr prompt
```

Print prompt.  Returns 1 if no session.

###### `init`

[`init`]: #init

```
kcr init <name>
```

Print functions.

###### `init kakoune`

[`init kakoune`]: #init-kakoune

```
kcr init kakoune
```

Print [Kakoune definitions].

[Kakoune definitions]: share/kcr/init/kakoune.kak

**Example** – **kakrc** configuration:

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

### Kakoune commands

###### [`connect`] | [`run`]

[Kakoune commands]: #kakoune-commands

```
connect <command> [arguments] ⇒ Run a command as <command> sh -c {connect} -- [arguments].  Example: connect terminal sh.
run <command> [arguments] ⇒ Run a program in a new session
```

###### `connect`

[`connect`]: #connect

```
connect <command> [arguments]
```

Run a command as `<command> sh -c {connect} -- [arguments]`.

**Example**

``` kak
connect terminal sh
```

###### `run`

[`run`]: #run

```
run <command> [arguments]
```

Run a program in a new session.

###### `init starship`

[`init starship`]: #init-starship

```
kcr init starship
```

Print [🚀][Starship] [Starship configuration].

[Starship]: https://starship.rs
[Starship configuration]: share/kcr/init/starship.toml

###### `install`

[`install`]: #install

```
kcr install <name>
```

Install files.

###### `install commands`

[`install commands`]: #install-commands

```
kcr install commands
```

Install [commands][Shipped commands].

[Shipped commands]: share/kcr/commands

###### `install desktop`

[`install desktop`]: #install-desktop

```
kcr install desktop
```

Install [desktop application].

[Desktop application]: share/kcr/applications/kcr.desktop

###### `env`

[`env`]: #env

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
  "KAKOUNE_VERSION": "*******"
}
```

###### `play`

[`play`]: #play

```
kcr play [file]
```

Start playground with [`example.kak`] by default.

[`example.kak`]: share/kcr/init/example.kak

###### `create`

[`create`]: #create

```
kcr create [session]
```

Create a new session.

###### `attach`

[`attach`]: #attach

```
kcr attach [session]
```

Connect to session.

###### `kill`

[`kill`]: #kill

```
kcr kill [session]
```

Kill session.

###### `list`

[`list`]: #list

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

[`shell`]: #shell

```
kcr shell [-d, --working-directory <path>] [command] [arguments]
```

Start an interactive shell.

**Example**

``` sh
kcr shell kcr attach
```

###### `edit`

[`edit`]: #edit

```
kcr edit [files] [input: fifo]
```

Edit files.

###### `open`

[`open`]: #open

```
kcr open [files] [input: fifo]
```

Open files.

###### `send`

[`send`]: #send

```
kcr send <command> [arguments] [input: json-format]
```

Send commands to client at session.

**Example**

``` sh
kcr send echo tchou
```

### Multiple commands

[Multiple commands]: #multiple-commands

It is possible to send multiple commands in a single request with pipes.

``` sh
kcr echo -- echo kanto |
kcr echo - echo johto |
kcr send -
```

### Nested commands

[Nested commands]: #nested-commands

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

[`echo`]: #echo

```
kcr echo [arguments] [input: data-stream]
```

Print arguments.

**Example**

``` sh
kcr echo -- echo tchou
```

Output:

``` json
["echo", "tchou"]
```

**Example** – Streaming data:

``` sh
kcr echo -- evaluate-commands -draft {} |
kcr echo - execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>' |
jq --slurp
```

Output:

``` json
[
  ["evaluate-commands", "-draft", "{}"],
  ["execute-keys", "<a-i>b", "i<backspace><esc>", "a<del><esc>"]
]
```

###### `get`

[`get`]: #get

```
kcr get [-V, --value <name>] [-O, --option <name>] [-R, --register <name>] [-S, --shell <command>] [expansions] [input: data-stream]
```

Get [states][Expansions] from a client in session.

[Expansions]: https://github.com/mawww/kakoune/blob/master/doc/pages/expansions.asciidoc

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
kcr get - %val{buflist} |
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

[`cat`]: #cat

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

###### `pipe`

[`pipe`]: #pipe

```
kcr pipe <program> [arguments] [input: json-selections]
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

[`escape`]: #escape

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

See also [Multiple commands] and [Nested commands].

###### `help`

[`help`]: #help

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

``` sh
kcr play
```

See the [`play`] command and [`example.kak`] file.

Learn more with [`doc`] and [`init kakoune`].

## Troubleshooting

[Troubleshooting]: #troubleshooting

Use the [`--debug`] ([`-d`]) flag or set [`$KAKOUNE_DEBUG`] to write a log message in the terminal and in Kakoune if available (see the `*debug*` buffer).

**Example**

``` sh
kcr --debug send -- echo tchou
```

Output:

``` json
{
  "session": "kanto",
  "client": "main",
  "arguments": [["echo", "tchou"]]
}
```

See [#2] for `'connect' no such command: 'popup'` error.

[#2]: https://github.com/alexherbo2/kakoune.cr/issues/2
