# `fzf`

[fzf] integration for **kcr**.

[fzf]: https://github.com/junegunn/fzf

## Dependencies

- [bat]
- [fd]
- [ripgrep]

[bat]: https://github.com/sharkdp/bat
[fd]: https://github.com/sharkdp/fd
[ripgrep]: https://github.com/BurntSushi/ripgrep

## Usage

```
kcr [-s, --session <name>] [-c, --client <name>] fzf <command> [arguments]
```

## Configuration

Kakoune example configuration:

`~/.config/kak/kakrc`

``` kak
map -docstring 'file picker' global normal <c-f> ': connect popup kcr fzf files<ret>'
map -docstring 'buffer picker' global normal <c-b> ': connect popup kcr fzf buffers<ret>'
map -docstring 'grep picker' global normal <c-g> ': connect popup kcr fzf grep<ret>'
map -docstring 'grep picker (buffer)' global normal <c-r> ': connect popup kcr fzf grep %val{buflist}<ret>'
```

Bash example configuration:

`~/.bashrc`

``` sh
alias K='kcr-fzf-shell'
alias KK='K --working-directory .'

# Open files _from_ and _to_ a session.
# $ :f src
# $ f: mawww/kakoune
alias :f='kcr fzf files'
alias f:='KK kcr fzf files'
alias fm:='K sidetree --working-directory'

alias :g='kcr fzf grep'
alias g:='KK kcr fzf grep'
```

Environment variables example configuration:

`~/.profile`

``` sh
export FZF_DEFAULT_OPTS='--multi --layout=reverse --preview-window=down:60%'
```

## Commands

```
kcr fzf <command> [arguments] ⇒ Run fzf command
kcr fzf files [paths] ⇒ Open files
kcr fzf buffers [patterns] ⇒ Open buffers
kcr fzf grep [paths] ⇒ Open files by content
kcr fzf shell [command] [arguments] ⇒ Start an interactive shell
```

###### `fzf`

```
kcr fzf <command> [arguments]
```

Run fzf command.

###### `fzf files`

```
kcr fzf files [paths]
```

Open files.

###### `fzf buffers`

```
kcr fzf buffers [patterns]
```

Open buffers.

###### `fzf grep`

```
kcr fzf grep [paths]
```

Open files by content.

###### `fzf shell`

```
kcr fzf shell [command] [arguments]
```

Start an interactive shell.

**Example**

``` sh
kcr fzf shell kcr attach
```
