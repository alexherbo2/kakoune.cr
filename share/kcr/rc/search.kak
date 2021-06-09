# Internal variables
declare-option -hidden str-list search_register
declare-option -hidden str-list search_selections

# Faces
set-face global SearchBackground 'white'
set-face global SearchOccurrence 'yellow+b'

# Search command
define-command -override search -docstring 'search' %{
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
  prompt search: '' -on-change %{
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
