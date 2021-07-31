# Search

try %{ declare-user-mode search }

define-command -override search -docstring 'search' %{
  enter-user-mode search
}

# Options ──────────────────────────────────────────────────────────────────────

# Internal variables
declare-option -hidden str-list search_register
declare-option -hidden str-list search_selections

# Faces
set-face global SearchBackground 'white'
set-face global SearchOccurrence 'yellow+b'

# Mappings ─────────────────────────────────────────────────────────────────────

# Reference:
# https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=SelectMode
map -docstring 'replace' global search r ':search-replace<ret>'
map -docstring 'extend' global search e ':search-extend<ret>'
map -docstring 'append' global search a ':search-append<ret>'

# Commands ─────────────────────────────────────────────────────────────────────

define-command -override search-replace -docstring 'search (replace)' %{
  search-implementation replace ''
}

define-command -override search-extend -docstring 'search (extend)' %{
  search-implementation extend %{
    execute-keys '<space>"mZ<c-o>Z<space>"m<a-z>u<a-z>a'
  }
}

define-command -override search-append -docstring 'search (append)' %{
  search-implementation append %{
    execute-keys '<space>"mZ<c-o>Z"mz<a-z>a'
  }
}

define-command -override -hidden search-implementation -params 2 -docstring 'search-implementation <select-mode-name> <select-mode-command>' %{
  # Save values
  set-option window search_register %reg{/}
  set-option window search_selections %val{selections_desc}

  # Save position
  execute-keys <c-s>

  # Paint background
  add-highlighter window/search-background fill SearchBackground
  add-highlighter window/search-wrap wrap -word

  # Highlight search occurrences
  add-highlighter window/search-occurrence regex "%reg{/}" 0:SearchOccurrence

  # Internal mappings
  map -docstring 'next' window prompt <tab> '<a-;>n'
  map -docstring 'previous' window prompt <s-tab> '<a-;><a-n>'
  map -docstring 'window top' window prompt <c-t> '<a-;>gt<a-;>n'
  map -docstring 'window bottom' window prompt <c-b> '<a-;>gb<a-;>gl<a-;>l<a-;><a-n>'

  # Clean up when leaving the prompt
  hook -always -once window ModeChange 'pop:prompt:normal' %{
    unmap window prompt
    remove-highlighter window/search-occurrence
    remove-highlighter window/search-background
    remove-highlighter window/search-wrap
  }

  # Enter search
  prompt "search (%arg{1}):" %arg{2} -on-change %{
    # Update search
    set-register / %val{text}

    # Highlight search occurrences
    hook -group show-search -always -once window User 'prompt=' %{
      set-register / %opt{search_register}
      add-highlighter -override window/search-occurrence regex "%reg{/}" 0:SearchOccurrence
    }
    try %{
      add-highlighter -override window/search-occurrence regex %val{text} 0:SearchOccurrence
      trigger-user-hook "prompt=%val{text}"
    } catch %{
      remove-highlighter window/search-occurrence
    }
    remove-hooks window show-search
  } -on-abort %{
    # Restore search and selections
    set-register / %opt{search_register}
    select %opt{search_selections}
  }
}
