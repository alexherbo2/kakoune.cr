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
    setsid "$@" < /dev/null > /dev/null 2>&1 &
  }
}

define-command -override connect-program -params 1.. -shell-completion -docstring 'Connect a program' %{
  connect run %arg{@}
}

define-command -override connect-terminal -params .. -shell-completion -docstring 'Connect a terminal' %{
  connect terminal %arg{@}
}

define-command -override connect-popup -params .. -shell-completion -docstring 'Connect a popup' %{
  connect popup %arg{@}
}

# Aliases
alias global $ connect-program
alias global > connect-terminal
alias global + connect-popup
