#compdef _runner runner

_runner() {
  local ret=1
  local -a context state line
  local -A opt_args

  local -a commands=(
    'secrets:Manage secrets'
  )

  _arguments -C \
    "1: :->command_or_file" \
    "*--vars[Set runner variable]:variable:_runner_var_completion" \
    "*--secrets[Load secret]:secret:_runner_secret_completion" \
    && ret=0

  case $state in
    command_or_file)
      if [[ ${CURRENT} -eq 2 ]]; then
        # First argument: 'secrets' or a workflow file
        local -a workflows
        workflows=( *.sh(N) )

        _alternative \
          'commands:command:(secrets)' \
          'files:workflow file:_files -g "*.sh"' \
          && ret=0
      fi
      ;;
  esac

  # Handle 'secrets' subcommand
  if [[ ${words[2]} == "secrets" ]]; then
    _runner_secrets_completion && ret=0
  fi

  return ret
}

_runner_secrets_completion() {
  local -a secret_commands=(
    'create:Create a new secret'
    'edit:Edit an existing secret'
    'view:View a secret'
    'delete:Delete a secret'
    'list:List all secrets'
  )

  _describe 'secrets command' secret_commands

  return 0
}

_runner_var_completion() {
  _message 'variable assignment (NAME=value)'
  return 0
}

_runner_secret_completion() {
  _message 'secret name'
  return 0
}
