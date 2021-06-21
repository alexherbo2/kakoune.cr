# Surround selections
# Reference: https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=select_object

# Surround mode
try %{ declare-user-mode surround }

define-command -override surround -docstring 'surround' %{
  enter-user-mode surround
}

# Initialization
define-command -override -hidden surround-init %{
  # Enter text
  map -docstring 'enter insert mode' global surround i ':surround-enter-insert-mode<ret>'
  map -docstring 'key' global surround k ':surround-key<ret>'
  map -docstring 'tag' global surround t ':surround-tag<ret>'

  # Editing
  map -docstring 'space' global surround <space> ':surround-add-space<ret>'
  map -docstring 'line' global surround <ret> ':surround-add-line<ret>'
  map -docstring 'delete' global surround <backspace> ':surround-delete<ret>'
  map -docstring 'delete' global surround <del> ':surround-delete<ret>'

  # Surrounding pairs
  declare-surrounding-pair 'parenthesis block' b ( )
  declare-surrounding-pair 'brace block' B { }
  declare-surrounding-pair 'bracket block' r [ ]
  declare-surrounding-pair 'angle block' a <lt> <gt>
  declare-surrounding-pair 'double quote string' Q '"' '"'
  declare-surrounding-pair 'single quote string' q "'" "'"
  declare-surrounding-pair 'grave quote string' g ` `
  declare-surrounding-pair 'double quotation mark' <a-Q> “ ”
  declare-surrounding-pair 'single quotation mark' <a-q> ‘ ’
  declare-surrounding-pair 'double angle quotation mark' <a-G> « »
  declare-surrounding-pair 'single angle quotation mark' <a-g> ‹ ›

  # Emphasis
  map -docstring 'emphasis' global surround _ ':surround-add _ _<ret>'
  map -docstring 'strong' global surround * ':surround-add ** **<ret>'
}

# Commands ─────────────────────────────────────────────────────────────────────

# Declare surrounding pairs
define-command -override declare-surrounding-pair -params 4 -docstring 'declare-surrounding-pair <description> [alias] <opening> <closing>: declare surrounding pair' %{
  try %{ map -docstring %arg{1} global surround %arg{2} ":surround-add %%🐈%arg{3}🐈 %%🐈%arg{4}🐈<ret>" }
  try %{ map -docstring %arg{1} global surround %arg{3} ":surround-add %%🐈%arg{3}🐈 %%🐈%arg{4}🐈<ret>" }
  try %{ map -docstring %arg{1} global surround %arg{4} ":surround-add %%🐈%arg{3}🐈 %%🐈%arg{4}🐈<ret>" }
}

# Enter insert mode
define-command -override -hidden surround-enter-insert-mode -docstring 'surround: enter insert mode' %{
  execute-keys -save-regs '' 'Z'
  hook -always -once window ModeChange 'pop:insert:normal' %{
    hook -always -once window ModeChange 'pop:insert:normal' %{
      execute-keys z
      set-register ^
      echo
    }
    execute-keys -with-hooks a
  }
  execute-keys -with-hooks i
}

# Surround key
define-command -override -hidden surround-key -docstring 'surround key' %{
  on-key %{
    surround-add %val{key} %val{key}
  }
}

# Surround tag
define-command -override -hidden surround-tag -docstring 'surround tag' %{
  prompt surround-tag: %{
    surround-add "<%val{text}>" "</%val{text}>"
  }
}

# Surround selected text
define-command -override -hidden surround-add -params 2 %{
  execute-keys-with-register P %arg{1}
  execute-keys-with-register p %arg{2}
}

define-command -override -hidden surround-add-space %{
  surround-add ' ' ' '
}

define-command -override -hidden surround-add-line %{
  # Extract selected text on its own line; clean whitespaces around the selection.
  try %{ execute-keys -draft 'i<ret><esc>kgl<a-i><space>d' }
  try %{ execute-keys -draft 'a<ret><esc>jgl<a-i><space>d' }

  # Indent selection
  execute-keys -draft '<a-:><a-;>K<a-:>J<a-&>'
  execute-keys -draft '<gt>'
}

# Delete surrounding
define-command -override -hidden surround-delete %{
  # Tag support
  try %{
    execute-keys 'y<a-a>c<lt>.+?<gt>,<lt>/.+?<gt><ret>R'
  } catch %{
    # Delete left surrounding
    try %{
      execute-keys -draft '<a-:><a-;>h<a-a><space>d'
    } catch %{
      execute-keys -draft 'i<backspace>'
    }

    # Delete right surrounding
    try %{
      execute-keys -draft '<a-:>l<a-a><space>d'
    } catch %{
      execute-keys -draft 'a<del>'
    }
  }
}

# Initialization
surround-init
