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

create_from_template() {
  local template_file="$1"
  local output_file="$2"

  if [[ ! -f "$template_file" ]]; then
    echo "Error: Template file $template_file not found" >&2
    return 1
  fi

  if envsubst < "$template_file" > "$output_file"; then
    echo "Created $output_file"
    return 0
  else
    echo "Failed to create $output_file"
    return 1
  fi
}
