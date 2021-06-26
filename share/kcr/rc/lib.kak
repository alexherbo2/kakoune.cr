declare-option str cursor_character_unicode

define-command -override add-cursor-character-unicode-expansion -docstring 'add %opt{cursor_character_unicode} expansion' %{
  remove-hooks global update-cursor-character-unicode-expansion
  hook -group update-cursor-character-unicode-expansion global NormalIdle '' %{
    set-option window cursor_character_unicode %sh{printf '%04x' "$kak_cursor_char_value"}
  }
}

define-command -override delete-scratch-message -docstring 'delete scratch message' %{
  remove-hooks global delete-scratch-message
  hook -group delete-scratch-message global BufCreate '\*scratch\*' %{
    execute-keys '%d'
  }
}

declare-option -docstring 'find command' str find_command 'fd --type file'

define-command -override find -menu -params 1 -shell-script-candidates %opt{find_command} -docstring 'open file' %{
  edit %arg{1}
}

alias global f find

define-command -override open-kakrc -docstring 'open kakrc' %{
  edit "%val{config}/kakrc"
}

define-command -override source-kakrc -docstring 'source kakrc' %{
  source "%val{config}/kakrc"
}

define-command -override evaluate-selections -docstring 'evaluate selections' %{
  evaluate-commands -itersel %{
    evaluate-commands %val{selection}
  }
}

alias global = evaluate-selections

define-command -override execute-keys-with-register -params 2 -docstring 'execute keys with register' %{
  evaluate-commands -save-regs '"' %{
    set-register '"' %arg{2}
    execute-keys '""' %arg{1}
  }
}

define-command -override enter-insert-mode-with-main-selection -docstring 'enter insert mode with main selection and iterate selections with Alt+N and Alt+P' %{
  execute-keys -save-regs '' '<a-:><a-;>Z<space>i'

  # Internal mappings
  map -docstring 'iterate next selection' window insert <a-n> '<a-;>z<a-;>)<a-;>Z<a-;><space>'
  map -docstring 'iterate previous selection' window insert <a-p> '<a-;>z<a-;>(<a-;>Z<a-;><space>'

  hook -always -once window ModeChange 'pop:insert:normal' %{
    execute-keys z
    unmap window insert
  }
}

define-command -override select-next-word -docstring 'select next word' %{
  evaluate-commands -itersel %{
    hook -group select-next-word -always -once window User "%val{selection_desc}" %{
      search-next-word
    }
    try %{
      execute-keys '<a-i>w'
      trigger-user-hook "%val{selection_desc}"
    } catch %{
      search-next-word
    }
    remove-hooks window select-next-word
  }
}

define-command -override -hidden search-next-word -docstring 'search next word' %{
  execute-keys 'h/\W\w<ret><a-i>w'
}

# Reference: https://code.visualstudio.com/docs/getstarted/keybindings#_basic-editing
define-command -override move-lines-down -docstring 'move line down' %{
  execute-keys -draft '<a-x><a-_><a-:>Z;ezj<a-x>dzP'
}

define-command -override move-lines-up -docstring 'move line up' %{
  execute-keys -draft '<a-x><a-_><a-:><a-;>Z;bzk<a-x>dzp'
}

define-command -override select-highlights -docstring 'select all occurrences of current selection' %{
  execute-keys '"aZ*%s<ret>"bZ"az"b<a-z>a'
}

define-command -override sort-selections -docstring 'sort selections' %{
  $ kcr pipe jq sort
}

define-command -override reverse-selections -docstring 'reverse selections' %{
  $ kcr pipe jq reverse
}

define-command -override math -docstring 'math' %{
  prompt math: %{
    execute-keys-with-register 'a<c-r>"<esc>|bc<ret>' %val{text}
  }
}

set-face global SelectedText 'default,bright-black'

define-command -override show-selected-text -docstring 'show selected text' %{
  remove-hooks global show-selected-text
  hook -group show-selected-text global NormalIdle '' update-selected-text-highlighter
  hook -group show-selected-text global InsertIdle '' update-selected-text-highlighter
}

define-command -override hide-selected-text -docstring 'hide selected text' %{
  remove-hooks global show-selected-text
  remove-highlighter global/selected-text
}

define-command -override -hidden update-selected-text-highlighter -docstring 'update selected text highlighter' %{
  evaluate-commands -draft -save-regs '/' %{
    try %{
      execute-keys '<a-k>..<ret>'
      execute-keys -save-regs '' '*'
      add-highlighter -override global/selected-text regex "%reg{/}" 0:SelectedText
    } catch %{
      remove-highlighter global/selected-text
    }
  }
}

set-face global Search 'black,bright-yellow'

define-command -override show-search -docstring 'show search' %{
  remove-hooks global show-search
  hook -group show-search global RegisterModified '/' %{
    try %{
      add-highlighter -override global/search regex "%reg{/}" 0:Search
    } catch %{
      remove-highlighter global/search
    }
  }
}

define-command -override hide-search -docstring 'hide search' %{
  remove-hooks global show-search
  remove-highlighter global/search
}

declare-option -hidden str-list palette

define-command -override show-palette -docstring 'show palette' %{
  evaluate-commands -draft %{
    # Select the viewport
    execute-keys 'gtGb'
    # Select colors
    execute-keys '2s(#|rgb:)([0-9A-Fa-f]{6})<ret>'
    set-option window palette %reg{.}
  }
  info -anchor "%val{cursor_line}.%val{cursor_column}" -markup %sh{
    printf '{rgb:%s}██████{default}\n' $kak_opt_palette
  }
}

define-command -override set-indent -params 2 -docstring 'set-indent <scope> <width>: set indent in <scope> to <width>' %{
  set-option %arg{1} tabstop %arg{2}
  set-option %arg{1} indentwidth %arg{2}
}

define-command -override enable-detect-indent -docstring 'enable detect indent' %{
  remove-hooks global detect-indent
  hook -group detect-indent global BufOpenFile '.*' detect-indent
  hook -group detect-indent global BufWritePost '.*' detect-indent
}

define-command -override disable-detect-indent -docstring 'disable detect indent' %{
  remove-hooks global detect-indent
  evaluate-commands -buffer '*' %{
    unset-option buffer tabstop
    unset-option buffer indentwidth
  }
}

define-command -override detect-indent -docstring 'detect indent' %{
  try %{
    evaluate-commands -draft %{
      # Search the first indent level
      execute-keys 'gg/^\h+<ret>'

      # Tabs vs. Spaces
      # https://youtu.be/V7PLxL8jIl8
      try %{
        execute-keys '<a-k>\t<ret>'
        set-option buffer tabstop 8
        set-option buffer indentwidth 0
      } catch %{
        set-option buffer tabstop %val{selection_length}
        set-option buffer indentwidth %val{selection_length}
      }
    }
  }
}

define-command -override enable-auto-indent -docstring 'enable auto-indent' %{
  remove-hooks global auto-indent
  hook -group auto-indent global InsertChar '\n' %{
    # Copy previous line indent
    try %{ execute-keys -draft 'K<a-&>' }
    # Clean previous line indent
    try %{ execute-keys -draft 'k<a-x>s^\h+$<ret>d' }
  }
}

define-command -override disable-auto-indent -docstring 'disable auto-indent' %{
  remove-hooks global auto-indent
}

# Documentation: https://xfree86.org/current/ctlseqs.html#:~:text=clipboard
define-command -override synchronize-clipboard -docstring 'synchronize clipboard' %{
  remove-hooks global synchronize-clipboard
  hook -group synchronize-clipboard global RegisterModified '"' %{
    nop %sh{
      encoded_selection_data=$(printf '%s' "$kak_main_reg_dquote" | base64)
      printf '\033]52;c;%s\a' "$encoded_selection_data" > /dev/tty
    }
  }
}

define-command -override synchronize-buffer-directory-name-with-register -params 1 -docstring 'synchronize buffer directory name with register' %{
  remove-hooks global "synchronize-buffer-directory-name-with-register-%arg{1}"
  hook -group "synchronize-buffer-directory-name-with-register-%arg{1}" global WinDisplay '.*' "
    save-directory-name-to-register %%val{hook_param} %arg{1}
  "
}

define-command -override -hidden save-directory-name-to-register -params 2 -docstring 'save-directory-name-to-register <path> <register>: save directory name to register' %{
  set-register %arg{2} %sh{printf '%s/' "${1%/*}"}
}
