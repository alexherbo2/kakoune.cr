# Edit me and press F5 to reload.
# Type in insert mode (), {}, []…
# Inspect the *debug* buffer populated with `kcr send --debug`.
# Open a connected terminal with [>] or [+] and try the `send` command with the --debug flag.
#
# Examples:
#
# kcr get %val{buflist}
#
# kcr echo -- echo kanto | kcr echo -- echo johto | kcr escape
# kcr echo -- kanto johto | kcr escape -- echo {}
#
# kcr echo -- echo kanto | kcr echo -- echo johto | kcr send -d
# kcr echo -- kanto johto | kcr send -d -- echo {}

$ sh -c %{
  time=$1

  kcr --debug send -- info 'Go ahead and experiment.'
  sleep $((time))

  kcr --debug send -- info 'Don’t think too much.'
  sleep $((time))

  kcr --debug send -- info 'Let intuition be your guide.'
  sleep $((time))

  kcr --debug send -- info 'Baten Kaitos: Eternal Wings and the Lost Ocean, in the Moonguile Forest, 2003.'
  sleep $((time * 2))

  kcr get %reg{.} |
  kcr --debug send -- info 'You have selected: {}'
} -- 2

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
    kcr send --debug
  }
}

define-command -override unmap-pairs %{
  $ sh -c %{
    kcr get %opt{pairs} |
    jq 'map(["unmap", "global", "insert", .])' |
    kcr send --debug
  }
}

map-pairs
