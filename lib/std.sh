#!/usr/bin/env bash

import_tasks() {
  local task_file="$1"

  if [[ ! -f "$task_file" ]]; then
    echo "import_tasks: file not found: $task_file" >&2
    return 1
  fi

  echo "Importing tasks from: $task_file" >&2
  #shellcheck disable=SC1090
  source "$task_file"
}
