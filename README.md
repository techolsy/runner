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
