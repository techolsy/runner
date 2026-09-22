#!/usr/bin/env bash

ssh_run() {
  local host="$1"
  shift

  if [[ -z "$host" ]]; then
    echo "ssh_run: missing host" >&2
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    echo "ssh_run: no command specified" >&2
    return 1
  fi

  ssh "$host" "$@"
}

ssh_script() {
  local host="$1"
  shift

  if [[ -z "$host" ]]; then
    echo "ssh_script: missing host" >&2
    return 1
  fi

  ssh "$host" 'bash -s' "$@"
}
