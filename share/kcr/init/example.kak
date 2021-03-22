# Edit me and press F5 to reload.
# Type in insert mode (), {}, []…
# Inspect the *debug* buffer populated with `kcr send --debug` or via `export KAKOUNE_DEBUG=1`.
# Open a connected terminal with [>] or [+] and try the following commands.
#
# Examples:
#
# export KAKOUNE_DEBUG=1
#
# kcr get %val{buflist}
#
# kcr echo -- echo kanto | kcr echo -- echo johto | kcr escape
# kcr echo -- kanto johto | kcr escape -- echo {}
#
# kcr echo -- echo kanto | kcr echo -- echo johto | kcr send
# kcr echo -- kanto johto | kcr send -- echo {}

define-command -override sort-selections %{
  map-selections sort
}

define-command -override map-selections -params 1.. %{
  $ sh -c %{
    kcr get %val{selections} |
    jq "$*" |
    jq '[["set-register", "dquote", .[]], ["execute-keys", "R"]]' |
    kcr send
  } -- %arg{@}
}

# ["Squirtle", "Bulbasaur", "Charmander"]

declare-option str-list pairs ( ) { } [ ]

define-command -override insert-opening-pair -params 2 %{
  execute-keys %arg{1} %arg{2} '<left>'
}

define-command -override insert-closing-pair -params 2 %{
  try %{
    execute-keys -draft ';' '<a-k>\Q' %arg{2} '<ret>'
    execute-keys '<right>'
  } catch %{
    execute-keys %arg{2}
  }
}

define-command -override map-pairs %{
  $ sh -c %{
    filter='
      _nwise(2) as [$opening, $closing] |

      ["map", "global", "insert", $opening, "<a-;>: {}<ret>"],
      ["insert-opening-pair", $opening, $closing],

      ["map", "global", "insert", $closing, "<a-;>: {}<ret>"],
      ["insert-closing-pair", $opening, $closing]
    '
    kcr get %opt{pairs} |
    jq "[$filter]" |
    kcr send
  }
}

define-command -override unmap-pairs %{
  $ sh -c %{
    kcr get %opt{pairs} |
    jq 'map(["unmap", "global", "insert", .])' |
    kcr send
  }
}

map-pairs
