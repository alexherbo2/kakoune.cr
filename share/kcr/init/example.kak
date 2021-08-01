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

# fzf integration.
#
# Usage:
#
# – Ctrl-f ⇒ Open files
# – Ctrl-b ⇒ Open buffers
#
# Dependencies:
#
# – fzf (https://github.com/junegunn/fzf)

define-command -override fzf-files %{
  connect popup sh -c %{
    fzf --preview 'cat {}' | xargs kcr edit --
  }
}

define-command -override fzf-buffers %{
  connect popup sh -c %{
    kcr get --raw --value buflist | fzf --preview 'kcr cat --raw {}' | xargs kcr send buffer --
  }
}

map global normal <c-f> ':fzf-files<ret>'
map global normal <c-b> ':fzf-buffers<ret>'

# ──────────────────────────────────────────────────────────────────────────────

# Pipe selections to an external filter program
# and replace the selections with its output.
#
# [1] kcr pipe jq sort
# [2] kcr pipe jq reverse
# [3] kcr pipe jq 'sort | reverse'
# [4] kcr get --value selections | jq sort | kcr pipe -

# ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

# Reimplementation of rotate_selections_content().
#
# https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=rotate_selections_content
#
# Usage:
#
# Select each Pokémon:
#
# ["Squirtle", "Bulbasaur", "Charmander"]
#
# Run the following command:
#
# rotate-selections-content
#
# Dependencies:
#
# – jq (https://stedolan.github.io/jq/)

define-command -override rotate-selections-content %{
  connect run kcr pipe jq '.[-1:] + .[:-1]'
}

# ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

# TL;DR
#
# curl -sSL https://github.com/rxi/json.lua/raw/master/json.lua -o json.lua
#
# Dependencies:
#
# – json.lua (https://github.com/rxi/json.lua)

define-command -override lua-index-selections %{
  connect run kcr pipe lua -l json -e %{
    local selections = json.decode(io.read('*a'))

    for index, selection in ipairs(selections) do
      selections[index] = string.format('%d. %s', index, selection)
    end

    io.write(json.encode(selections))
  }
}

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
  connect run sh -c %{
    filter='
      _nwise(2) as [$opening, $closing] |

      ["map", "global", "insert", $opening, "<a-;>: {}<ret>"],
      ["insert-opening-pair", $opening, $closing],

      ["map", "global", "insert", $closing, "<a-;>: {}<ret>"],
      ["insert-closing-pair", $opening, $closing]
    '
    kcr get %opt{pairs} |
    jq "[$filter]" |
    kcr send -
  }
}

define-command -override unmap-pairs %{
  connect run sh -c %{
    kcr get %opt{pairs} |
    jq 'map(["unmap", "global", "insert", .])' |
    kcr send -
  }
}

map-pairs
