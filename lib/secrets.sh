#!/usr/bin/env bash

SECRETS_DIR="$PWD/secrets"

secret_file() {
  local name="$1"

  printf '%s/%s.bin\n' "$SECRETS_DIR" "$name"
}

secret_encrypt() {
  local input="$1"
  local output="$2"
  local cmd=(
    "gpg"
    "-q"
    "--batch"
    "--yes"
    "-o"
    "$output"
    "-c"
    "--cipher-algo"
    "AES256"
    "$input"
  )
  
  if [[ -v RUNNER_VAULT_PASSWORD ]]; then
    cmd=("${cmd[@]:0:4}" "--passphrase" "$RUNNER_VAULT_PASSWORD" "${cmd[@]:4}")
  fi

  command "${cmd[@]}"
}

secret_decrypt() {
  local input="$1"
  local output="$2"
  local cmd=(
    "gpg"
    "-q"
    "--batch"
    "--yes"
    "-o"
    "$output"
    "--decrypt"
    "$input"
  )

  if [[ -v RUNNER_VAULT_PASSWORD ]]; then
    cmd=("${cmd[@]:0:4}" "--passphrase" "$RUNNER_VAULT_PASSWORD" "${cmd[@]:4}")
  fi

  command "${cmd[@]}"
}

secret_create() {
  local name="$1"
  local file
  local tmp

  file="$(secret_file "$name")"

  if [[ -e "$file" ]]; then
    echo "Secret already exists: $name" >&2
    return 1
  fi

  mkdir -p "$SECRETS_DIR"

  tmp="$(mktemp)"
  chmod 600 "$tmp"

  cat > "$tmp" <<'EOF'
# Runner secrets
#
# Format:
#
# NAME=value
#
# Lines beginning with # are ignored
EOF

  if ! "${EDITOR:-vi}" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  echo
  echo "Encrypting secret..."

  if ! secret_encrypt "$tmp" "$file"; then
    rm -f "$tmp"
    echo "Failed to encrypt secret: $name" >&2
    return 1
  fi

  rm -f "$tmp"
  chmod 600 "$file"

  echo "Created secret: $name"
}

secret_edit() {
  local name="$1"
  local file
  local tmp

  file="$(secret_file "$name")"

  if [[ ! -f "$file" ]]; then
    echo "Secret not found: $name" >&2
    return 1
  fi

  tmp="$(mktemp)"
  chmod 600 "$tmp"

  if ! secret_decrypt "$file" "$tmp"; then
    rm -f "$tmp"
    echo "Failed to decrypt secret: $name" >&2
    return 1
  fi

  if ! "${EDITOR:-vi}" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  echo
  echo "Encrypting updated secret..."

  if ! secret_encrypt "$tmp" "$file"; then
    rm -f "$tmp"
    echo "Failed to encrypt secret: $name" >&2
    return 1
  fi

  rm -f "$tmp"
  chmod 600 "$file"

  echo "Updated secret: $name"
}

secret_view() {
  local name="$1"
  local file
  local tmp

  file=$(secret_file "$name")

  if [[ ! -f "$file" ]]; then
    echo "Secret not found: $name" >&2
    return 1
  fi

  tmp="$(mktemp)"
  chmod 600 "$tmp"

  trap 'rm -f "$tmp"' RETURN

  if ! secret_decrypt "$file" "$tmp"; then
    echo "Failed to decrypt secret: $name" >&2
    return 1
  fi

  cat "$tmp"
}

secret_delete() {
  local name="$1"
  local file

  file="$(secret_file "$name")"

  if [[ ! -f "$file" ]]; then
    echo "Secret not found: $name" >&2
    return 1
  fi

  read -r -p "Delete secret '$name'? [y/N] " answer

  case "$answer" in
    y|Y|yes|YES)
      rm -f "$file"
      echo "Deleted secret: $name"
      ;;

    *)
      echo "Cancelled."
      ;;
  esac
}

secret_list() {
  local found=0
  local file

  mkdir -p "$SECRETS_DIR"

  for file in "$SECRETS_DIR"/*.bin; do
    [[ -f "$file" ]] || continue

    basename "$file" .bin
    found=1
  done

  if (( ! found )); then
    echo "No secrets found."
  fi
}

secret_load() {
  local name="$1"
  local file
  local tmp

  file=$(secret_file "$name")

  if [[ ! -f "$file" ]]; then
    echo "Secret not found: $name" >&2
    return 1
  fi

  tmp="$(mktemp)"
  chmod 600 "$tmp"

  if ! secret_decrypt "$file" "$tmp"; then
    rm -f "$tmp"
    echo "Failed to decrypt secret: $name" >&2
    return 1
  fi

  #shellcheck disable=SC1090
  source "$tmp"

  rm -f "$tmp"
}
