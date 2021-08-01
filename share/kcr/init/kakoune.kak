# Connect a program to Kakoune

try %{ declare-user-mode connect }

define-command -override connect-terminal -docstring 'connect terminal' %{
  enter-user-mode connect
}

# Mappings ─────────────────────────────────────────────────────────────────────

map -docstring 'default' global connect d ':connect terminal<ret>'
map -docstring 'horizontal' global connect h ':connect terminal-horizontal<ret>'
map -docstring 'vertical' global connect v ':connect terminal-vertical<ret>'
map -docstring 'tab' global connect t ':connect terminal-tab<ret>'
map -docstring 'window' global connect w ':connect terminal-window<ret>'
map -docstring 'popup' global connect + ':connect popup<ret>'
map -docstring 'panel' global connect <tab> ':connect panel<ret>'

# Commands ─────────────────────────────────────────────────────────────────────

define-command -override connect -params 1.. -command-completion -docstring 'Run a command as <command> sh -c {connect} -- [arguments].  Example: connect terminal sh' %{
  %arg{1} sh -c %{
    export KAKOUNE_SESSION=$1
    export KAKOUNE_CLIENT=$2
    shift 3

    [ $# = 0 ] && set "$SHELL"

    "$@"
  } -- %val{session} %val{client} %arg{@}
}

define-command -override run -params 1.. -shell-completion -docstring 'Run a program in a new session' %{
  nop %sh{
    nohup "$@" < /dev/null > /dev/null 2>&1 &
  }
}
