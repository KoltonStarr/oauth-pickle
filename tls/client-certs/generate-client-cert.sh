#!/usr/bin/env bash
# Generate a client key and certificate signed by the internal CA.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CA_DIR="$ROOT_DIR/ca"

if [ ! -f "$CA_DIR/certs/ca.cert.pem" ] || [ ! -f "$CA_DIR/private/ca.key.pem" ]; then
  echo "CA not found. Run $CA_DIR/create-ca.sh first." >&2
  exit 1
fi

NAME="${1:-client}"
OUT_DIR="$SCRIPT_DIR/$NAME"
mkdir -p "$OUT_DIR"

CLIENT_KEY="$OUT_DIR/$NAME.key.pem"
CLIENT_CSR="$OUT_DIR/$NAME.csr.pem"
CLIENT_CERT="$OUT_DIR/$NAME.cert.pem"

openssl genrsa -out "$CLIENT_KEY" 2048

openssl req -new -key "$CLIENT_KEY" -subj "/CN=$NAME" -out "$CLIENT_CSR"

openssl x509 -req -in "$CLIENT_CSR" \
  -CA "$CA_DIR/certs/ca.cert.pem" -CAkey "$CA_DIR/private/ca.key.pem" \
  -CAcreateserial -out "$CLIENT_CERT" -days 365 -sha256

echo "Client certificate created at $CLIENT_CERT"
