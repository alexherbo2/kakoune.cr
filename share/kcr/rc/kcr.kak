define-command -override kcr-open-kakrc -docstring 'open kakoune.cr kakrc' %{
  $ sh -c %{
    kcr init kakoune | kcr edit -
    kcr send set-option 'buffer=*fifo*' filetype kak
  }
}

define-command -override kcr-open-doc -docstring 'open kakoune.cr documentation' %{
  $ sh -c %{
    kcr doc | kcr edit -
    kcr send set-option 'buffer=*fifo*' filetype asciidoc
  }
}
