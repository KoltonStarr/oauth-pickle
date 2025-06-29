#!/usr/bin/env bash
# Generate a server key and certificate signed by the internal CA.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CA_DIR="$ROOT_DIR/ca"

if [ ! -f "$CA_DIR/certs/ca.cert.pem" ] || [ ! -f "$CA_DIR/private/ca.key.pem" ]; then
  echo "CA not found. Run $CA_DIR/create-ca.sh first." >&2
  exit 1
fi

NAME="${1:-server}"
OUT_DIR="$SCRIPT_DIR/$NAME"
mkdir -p "$OUT_DIR"

SERVER_KEY="$OUT_DIR/$NAME.key.pem"
SERVER_CSR="$OUT_DIR/$NAME.csr.pem"
SERVER_CERT="$OUT_DIR/$NAME.cert.pem"

openssl genrsa -out "$SERVER_KEY" 2048

openssl req -new -key "$SERVER_KEY" -subj "/CN=$NAME" -out "$SERVER_CSR"

openssl x509 -req -in "$SERVER_CSR" \
  -CA "$CA_DIR/certs/ca.cert.pem" -CAkey "$CA_DIR/private/ca.key.pem" \
  -CAcreateserial -out "$SERVER_CERT" -days 365 -sha256

echo "Server certificate created at $SERVER_CERT"
