#!/usr/bin/env bash
# Generate random secrets used by lldap
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR/secrets"
mkdir -p "$SECRETS_DIR"

random() {
  tr -dc 'A-Za-z0-9!#%&()*+,-./:;<=>?@[\\]^_{|}~' </dev/urandom | head -c 32
}

[ -f "$SECRETS_DIR/jwt_secret" ] || random > "$SECRETS_DIR/jwt_secret"
[ -f "$SECRETS_DIR/key_seed" ] || random > "$SECRETS_DIR/key_seed"

if [ ! -f "$SECRETS_DIR/admin_pass" ]; then
  echo "admin" > "$SECRETS_DIR/admin_pass"
  echo "Default admin password written to $SECRETS_DIR/admin_pass. Change it." >&2
fi
