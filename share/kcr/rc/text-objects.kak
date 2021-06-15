# Matching pairs
set-option global matching_pairs ( ) { } [ ] < > “ ” ‘ ’ « » ‹ ›

# Quotation marks
map -docstring 'double quotation mark' global object <a-Q> 'c“,”<ret>'
map -docstring 'single quotation mark' global object <a-q> 'c‘,’<ret>'
map -docstring 'double angle quotation mark' global object <a-G> 'c«,»<ret>'
map -docstring 'single angle quotation mark' global object <a-g> 'c‹,›<ret>'

# Tag
map -docstring 'tag' global object t 'c<lt>.+?<gt>,<lt>/.+?<gt><ret>'

# Line
map -docstring 'line' global object x '<esc><a-x>_'
