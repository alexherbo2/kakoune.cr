# Select objects
# Reference: https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=select_object

# Select mode
try %{ declare-user-mode select }

define-command -override select-objects -docstring 'select objects' %{
  enter-user-mode select
}

# Mappings ─────────────────────────────────────────────────────────────────────

map -docstring 'select inner parenthesis blocks' global select b ':select-inner-parenthesis-blocks<ret>'
map -docstring 'select whole parenthesis blocks' global select <a-b> ':select-whole-parenthesis-blocks<ret>'
map -docstring 'select inner parenthesis blocks' global select ( ':select-inner-parenthesis-blocks<ret>'
map -docstring 'select whole parenthesis blocks' global select ) ':select-whole-parenthesis-blocks<ret>'

map -docstring 'select inner brace blocks' global select B ':select-inner-brace-blocks<ret>'
map -docstring 'select whole brace blocks' global select <a-B> ':select-whole-brace-blocks<ret>'
map -docstring 'select inner brace blocks' global select { ':select-inner-brace-blocks<ret>'
map -docstring 'select whole brace blocks' global select } ':select-whole-brace-blocks<ret>'

map -docstring 'select inner bracket blocks' global select r ':select-inner-bracket-blocks<ret>'
map -docstring 'select whole bracket blocks' global select <a-r> ':select-whole-bracket-blocks<ret>'
map -docstring 'select inner bracket blocks' global select [ ':select-inner-bracket-blocks<ret>'
map -docstring 'select whole bracket blocks' global select ] ':select-whole-bracket-blocks<ret>'

map -docstring 'select inner angle blocks' global select a ':select-inner-angle-blocks<ret>'
map -docstring 'select whole angle blocks' global select <a-a> ':select-whole-angle-blocks<ret>'
map -docstring 'select inner angle blocks' global select <lt> ':select-inner-angle-blocks<ret>'
map -docstring 'select whole angle blocks' global select <gt> ':select-whole-angle-blocks<ret>'

map -docstring 'select inner double quote strings' global select Q ':select-inner-double-quote-strings<ret>'
map -docstring 'select whole double quote strings' global select <a-Q> ':select-whole-double-quote-strings<ret>'
map -docstring 'select inner double quote strings' global select '"' ':select-inner-double-quote-strings<ret>'
map -docstring 'select whole double quote strings' global select '<a-">' ':select-whole-double-quote-strings<ret>'

map -docstring 'select inner single quote strings' global select q ':select-inner-single-quote-strings<ret>'
map -docstring 'select whole single quote strings' global select <a-q> ':select-whole-single-quote-strings<ret>'
map -docstring 'select inner single quote strings' global select "'" ':select-inner-single-quote-strings<ret>'
map -docstring 'select whole single quote strings' global select "<a-'>" ':select-whole-single-quote-strings<ret>'

map -docstring 'select inner grave quote strings' global select g ':select-inner-grave-quote-strings<ret>'
map -docstring 'select whole grave quote strings' global select <a-g> ':select-whole-grave-quote-strings<ret>'
map -docstring 'select inner grave quote strings' global select ` ':select-inner-grave-quote-strings<ret>'
map -docstring 'select whole grave quote strings' global select <a-`> ':select-whole-grave-quote-strings<ret>'

map -docstring 'select words' global select w ':select-words<ret>'
map -docstring 'select big words' global select <a-w> ':select-big-words<ret>'
map -docstring 'select sentences' global select s ':select-sentences<ret>'
map -docstring 'select paragraphs' global select p ':select-paragraphs<ret>'
map -docstring 'select whitespaces' global select <space> ':select-whitespaces<ret>'
map -docstring 'select indent' global select i ':select-indent<ret>'
map -docstring 'select numbers' global select n ':select-numbers<ret>'
map -docstring 'select arguments' global select u ':select-arguments<ret>'

# Commands ─────────────────────────────────────────────────────────────────────

define-command -override -hidden select-inner-parenthesis-blocks -docstring 'select inner parenthesis blocks' %{
  execute-keys 's\(<ret><a-i>b'
}

define-command -override -hidden select-whole-parenthesis-blocks -docstring 'select whole parenthesis blocks' %{
  execute-keys 's\(<ret><a-a>b'
}

define-command -override -hidden select-inner-brace-blocks -docstring 'select inner brace blocks' %{
  execute-keys 's\{<ret><a-i>B' # }
}

define-command -override -hidden select-whole-brace-blocks -docstring 'select whole brace blocks' %{
  execute-keys 's\{<ret><a-a>B' # }
}

define-command -override -hidden select-inner-bracket-blocks -docstring 'select inner bracket blocks' %{
  execute-keys 's\[<ret><a-i>r'
}

define-command -override -hidden select-whole-bracket-blocks -docstring 'select whole bracket blocks' %{
  execute-keys 's\[<ret><a-a>r'
}

define-command -override -hidden select-inner-angle-blocks -docstring 'select inner angle blocks' %{
  execute-keys 's<lt><ret><a-i>a'
}

define-command -override -hidden select-whole-angle-blocks -docstring 'select whole angle blocks' %{
  execute-keys 's<lt><ret><a-a>a'
}

define-command -override -hidden select-inner-double-quote-strings -docstring 'select inner double quote strings' %{
  execute-keys 's"[^"]*"<ret><a-;><a-i>Q'
}

define-command -override -hidden select-whole-double-quote-strings -docstring 'select whole double quote strings' %{
  execute-keys 's"[^"]*"<ret><a-;><a-a>Q'
}

define-command -override -hidden select-inner-single-quote-strings -docstring 'select inner single quote strings' %{
  execute-keys "s'[^']*'<ret><a-;><a-i>q"
}

define-command -override -hidden select-whole-single-quote-strings -docstring 'select whole single quote strings' %{
  execute-keys "s'[^']*'<ret><a-;><a-a>q"
}

define-command -override -hidden select-inner-grave-quote-strings -docstring 'select inner grave quote strings' %{
  execute-keys 's`[^`]*`<ret><a-;><a-i>g'
}

define-command -override -hidden select-whole-grave-quote-strings -docstring 'select whole grave quote strings' %{
  execute-keys 's`[^`]*`<ret><a-;><a-a>g'
}

define-command -override -hidden select-words -docstring 'select words' %{
  execute-keys 's\w+<ret><a-i>w'
}

define-command -override -hidden select-big-words -docstring 'select big words' %{
  execute-keys 's\w+<ret><a-i><a-w>'
}

define-command -override -hidden select-sentences -docstring 'select sentences' %{
  execute-keys 's[^\n]+<ret><a-i>s'
}

define-command -override -hidden select-paragraphs -docstring 'select paragraphs' %{
  execute-keys 's[^\n]+<ret><a-i>p'
}

define-command -override -hidden select-whitespaces -docstring 'select whitespaces' %{
  execute-keys 's\h+<ret><a-i><space>'
}

define-command -override -hidden select-indent -docstring 'select indent' %{
  execute-keys 's^\h+<ret><a-i><space>'
}

define-command -override -hidden select-numbers -docstring 'select numbers' %{
  execute-keys 's\d+<ret><a-i>n'
}

define-command -override -hidden select-arguments -docstring 'select arguments' %{
  execute-keys 's\(<ret><a-i>bs\w+<ret><a-i>u'
}
