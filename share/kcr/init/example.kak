# Edit me and press F5 to reload.
#
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

# ──────────────────────────────────────────────────────────────────────────────

# fzf integration with Nushell.
#
# Note:
#
# If you don’t have Nushell installed, edit this code for POSIX-compliance
# and press F5 to reload.
#
# Usage:
#
# – Ctrl-f ⇒ Open files
# – Ctrl-b ⇒ Open buffers
#
# Dependencies:
#
# – fzf (https://github.com/junegunn/fzf)
# – Nushell (https://nushell.sh)

define-command -override fzf-files %{
  + nu --commands %{
    fzf --preview 'cat {}' | lines | each { kcr edit $it }
  }
}

define-command -override fzf-buffers %{
  + nu --commands %{
    kcr get --raw --value buflist | fzf --preview 'kcr cat --raw {}' | lines | each { kcr send buffer $it }
  }
}

map global normal <c-f> ': fzf-files<ret>'
map global normal <c-b> ': fzf-buffers<ret>'

# ──────────────────────────────────────────────────────────────────────────────

# Map selections with jq.
#
# Usage:
#
# Select each Pokémon:
#
# ["Squirtle", "Bulbasaur", "Charmander"]
#
# Run the following command with Alt-pipe:
#
# map-selections sort | reverse
#
# Dependencies:
#
# – jq (https://stedolan.github.io/jq/)

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

map global normal <a-|> ': map-selections<space>'

# ──────────────────────────────────────────────────────────────────────────────

# Auto-paired characters with jq.
#
# Usage:
#
# Type in insert mode (), {}, []…
#
# Dependencies:
#
# – jq (https://stedolan.github.io/jq/)

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
