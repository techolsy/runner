#!/usr/bin/env bash

task "Check if version is set" <<'TASK'
if [[ ! -v VERSION ]]; then
  echo "version is not set"
  return 1
fi

echo "Installing version: $VERSION"
TASK

task "Check dependencies" <<'TASK'
deps=(
  "git"
  "gpg"
  "vi"
)

for dep in "${deps[@]}"; do
  if ! command -v "$dep"; then
    echo "Missing dependency: $dep"
    return 1
  fi
done
TASK

task "Clone runner into tmp dir" --var URL="https://github.com/techolsy/runner.git" <<'TASK'
repo_dir="$(mktemp -d)"
echo "$URL"
git clone --branch "$VERSION" "$URL" "$repo_dir"

persist repo_dir
TASK

task "Create directories" <<'TASK'
conf_dir="$HOME/.config/runner/bin"
mkdir -p "$conf_dir/lib"

persist conf_dir
TASK

task "Copy runner" <<'TASK'
for file in runner install.sh; do
  if [[ ! -f "$repo_dir/$file" ]]; then
    echo "Could not find: $file"
    return 1
  fi
  cp "$repo_dir/$file" "$conf_dir/$file"
  echo "Copied: $file"
done
TASK

task "Copy lib files" <<'TASK'
while read -r file; do
  cp "$repo_dir/lib/$file" "$conf_dir/lib/$file"
  echo "Copied: $file"
done < <(ls -1 "$repo_dir/lib")
TASK

task "Cleanup" <<'TASK'
rm -fr "$repo_dir"

forget repo_dir
forget conf_dir
TASK

task "Done" <<'TASK'
echo "Installed Version: $VERSION"
TASK
