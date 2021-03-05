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
map -docstring 'Open files' global normal <c-f> ': + kcr-fzf-files<ret>'
map -docstring 'Open buffers' global normal <c-b> ': + kcr-fzf-buffers<ret>'
map -docstring 'Open files by content' global normal <c-g> ': + kcr-fzf-grep<ret>'
```

Bash example configuration:

`~/.bashrc`

``` sh
alias K='kcr-fzf-shell'
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
