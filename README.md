# runner

A simple bash task runner for multi step workflows

## Quick Start

```bash
# Create a workflow
cat > build.sh << 'EOF'
task "compile" << 'TASK'
echo "Building..."
make build
TASK

task "test" << 'TASK'
echo "Testing..."
make test
TASK
EOF

# Run it
./runner build.sh
```

## Installation
You can use the runner to install the runner with `install.sh`
```bash
./runner install.sh --vars VERSION=<tag>
```

This will install the runner in `$HOME/.config/runner/bin/`

You can export that path in your `bashrc/zshrc`
```bash
export PATH="$HOME/.config/runner/bin:$PATH"
```

## Usage
```bash
./runner <workflow-file> [OPTIONS]
```

### Options
```bash
--vars NAME=value # Pass a variable to all tasks
--secrets NAME # Pass secrets to all tasks
```

## Defining Tasks
```bash
task "Task Name" [OPTIONS] <<'TASK'
# Commands here
echo "Hello from task"
TASK
```

### Options
```bash
--var NAME=value # Set a variable name for this task only
--secret NAME # Use a stored secret in this task only
```

## Managing secrets

### Create a secret
```bash
./runner secrets create <name>
```

### Edit a secret
```bash
./runner secrets edit <name>
```

### View a secret
```bash
./runner secrets view <name>
```

### Delete a secret
```bash
./runner secrets delete <name>
```

### List secrets
```bash
./runner secrets list
```

## Persisting Variables Accrosss Tasks

### Use `persist` in a task to save a variable for subsequent tasks
```bash
task "Generate token" <<'TASK'
TOKEN="$(generate_auth_token)"
persist TOKEN
TASK

task "Use token" <<'TASK'
echo "Token: $TOKEN"
TASK
```

### Use `forget` to remove a saved variable
```bash
task "Cleanup" <<'TASK'
forget TOKEN
TASK
```

## Importing Tasks From Other Files
Use `import_tasks` to load tasks from another file
```bash
# workflow.sh
import_tasks "tasks/build.sh"
import_tasks "tasks/deploy.sh"
```

## Generating Files From Templates
```bash
task "Generate template file" \
  --var APP_VERSION=1.2.3 \
  --var DATABASE_HOST=localhost \
  << 'TASK'
create_from_template "templates/config.env.template" "config.env"
TASK
```

### Template file `templates/config.env.template`
```text
APP_NAME=MyApp
APP_VERSION=$APP_VERSION
DATABASE_HOST=$DATABASE_HOST
```

### Result file `config.env`
```text
APP_NAME=MyApp
APP_VERSION=1.2.3
DATABASE_HOST=localhost
```

### Notes:
    * Uses envsubst to replace variables
    * All exported variables will be substituted
    * Non-existent variables will be replaced with empty strings

## Directory Structure
```text
Project/
|-- secrets
|   |-- api.bin
|   `-- passwords.bin
|-- tasks
|   |-- create.sh
|   `-- configure.sh
|-- vars
|   `-- users.sh
`-- workflows
    |-- build.sh
    `-- publish.sh
```

## Interactive Failure Handling

### When a task fails you get 4 options:
    * [r]Retry - Run the task again
    * [e]Edit - Edit the task commands and run it
    * [s]Skip - Skip to next task
    * [a]Abort - Stop the entire workflow
