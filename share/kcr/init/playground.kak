define-command -override initialize -params 1 -file-completion -docstring 'Initialize the playground' %{
  edit -fifo %arg{1} '*playground*'
  set-option buffer filetype kak
  map -docstring 'Reload the playground' buffer normal <F5> ':reload<ret>'
  info -title Playground 'Press F5 or enter :reload to reload the *playground* buffer'
}

define-command -override reload -docstring 'Reload the playground' %{
  connect run sh -c %{
    playground=$(kcr cat --raw '*playground*')
    kcr send evaluate-commands "$playground"
  }
}
