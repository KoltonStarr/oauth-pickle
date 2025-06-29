#!/usr/bin/env bash
# Simple script to create a local root certificate authority.
# All artifacts are stored in the same directory as this script.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CA_DIR="$SCRIPT_DIR"

mkdir -p "$CA_DIR/certs" "$CA_DIR/private" "$CA_DIR/newcerts"
chmod 700 "$CA_DIR/private"

# Initialize files used by OpenSSL
[ -f "$CA_DIR/index.txt" ] || touch "$CA_DIR/index.txt"
[ -f "$CA_DIR/serial" ] || echo 1000 > "$CA_DIR/serial"

CA_KEY="$CA_DIR/private/ca.key.pem"
CA_CERT="$CA_DIR/certs/ca.cert.pem"

if [ -f "$CA_CERT" ]; then
  echo "CA certificate already exists at $CA_CERT"
  exit 0
fi

# Generate private key
openssl genrsa -out "$CA_KEY" 4096

# Self-sign the root certificate
openssl req -x509 -new -nodes -key "$CA_KEY" \
  -sha256 -days 3650 \
  -subj "/CN=Example Internal Root CA" \
  -out "$CA_CERT"

echo "Root CA created at $CA_CERT"
