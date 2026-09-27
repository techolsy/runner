#!/usr/bin/env bash

msg() {
    local color="$1"
    local message="$2"
    local color_code=""
    
    case "$color" in
        red)        color_code="\033[31m" ;;
        green)      color_code="\033[32m" ;;
        yellow)     color_code="\033[33m" ;;
        blue)       color_code="\033[34m" ;;
        magenta)    color_code="\033[35m" ;;
        cyan)       color_code="\033[36m" ;;
        white)      color_code="\033[37m" ;;
        *)          color_code="" ;;
    esac
    
    printf "%b%s%b\n" "$color_code" "$message" "\033[0m"
}

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
