# Guide

## Configuration

Kakoune example configuration:

`~/.config/kak/kakrc`

``` kak
# Preamble
evaluate-commands %sh{
  kcr init kakoune
}

# Mappings
map -docstring 'connect mode' global normal <c-t> ': connect-mode<ret>'
map -docstring 'file explorer' global normal <c-e> ': connect panel sidetree --select %val{buffile}<ret>'
map -docstring 'file picker' global normal <c-f> ': connect popup kcr fzf files<ret>'
map -docstring 'buffer picker' global normal <c-b> ': connect popup kcr fzf buffers<ret>'
map -docstring 'grep picker' global normal <c-g> ': connect popup kcr fzf grep<ret>'
map -docstring 'grep picker (buffer)' global normal <c-r> ': connect popup kcr fzf grep %val{buflist}<ret>'
map -docstring 'git' global normal <c-l> ': connect popup gitui<ret>'
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

# Open files _from_ and _to_ a session.
# $ :f src
# $ f: mawww/kakoune
alias :f='kcr fzf files'
alias f:='KK kcr fzf files'
alias fm:='K sidetree --working-directory'

alias :g='kcr fzf grep'
alias g:='KK kcr fzf grep'
```

[Environment variables] example configuration:

`~/.profile`

``` sh
export EDITOR='kcr edit'
export FZF_DEFAULT_OPTS='--multi --layout=reverse --preview-window=down:60%'
```

[Environment variables]: https://wiki.archlinux.org/title/Environment_variables

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

[XDG MIME Applications]: https://wiki.archlinux.org/title/XDG_MIME_Applications

## Writing plugins

``` sh
kcr play
```

See the [`play`] command and [`example.kak`] file.

[`play`]: manual.md#play
[`example.kak`]: ../share/kcr/init/example.kak
