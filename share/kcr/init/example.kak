# Edit me and press F5 to reload.
#
# Inspect the *debug* buffer populated with `kcr send --debug` or via `export KAKOUNE_DEBUG=1`.
#
# Open a connected terminal with [>] or [+] and experiment the following commands.
#
# [1] kcr get %val{buflist}
# [2] kcr get --value buflist
# [3] kcr get --raw --value buflist
# [4] kcr get --raw --value buflist | fzf
# [5] kcr cat
# [6] kcr cat --raw
# [7] kcr cat --raw '*scratch*'
# [8] kcr get --raw --value buflist | fzf --preview 'kcr cat --raw {}'
# [9] kcr get --raw --value buflist | fzf --preview 'kcr cat --raw {}' | while read name
# do kcr send buffer "$name"
# done

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
