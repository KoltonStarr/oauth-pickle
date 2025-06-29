#!/usr/bin/env bash
# Start an OpenLDAP container with persistent storage and TLS using an internal CA.
# This script works on macOS and Linux as long as Docker is installed.

set -e

# Location of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Directories for persistent data and configuration
DATA_DIR="$ROOT_DIR/data"
CONFIG_DIR="$ROOT_DIR/config"
CERT_DIR="$ROOT_DIR/certs"

mkdir -p "$DATA_DIR" "$CONFIG_DIR" "$CERT_DIR"

# These files should be provided by your internal CA
CA_CRT="$CERT_DIR/ca.crt"
SERVER_CRT="$CERT_DIR/server.crt"
SERVER_KEY="$CERT_DIR/server.key"

# Build the Docker image (located in ldap/docker)
docker build -t ldap-example "$ROOT_DIR/docker"

# Run the container
# 389: LDAP without TLS
# 636: LDAP over TLS (LDAPS)
docker run -d --name ldap-server \
  -p 389:389 -p 636:636 \
  -v "$DATA_DIR:/var/lib/ldap" \
  -v "$CONFIG_DIR:/etc/ldap/slapd.d" \
  -v "$CERT_DIR:/container/service/slapd/assets/certs" \
  -e LDAP_ORGANISATION="Example Org" \
  -e LDAP_DOMAIN="example.org" \
  -e LDAP_ADMIN_PASSWORD="admin" \
  -e LDAP_TLS=true \
  -e LDAP_TLS_CRT_FILENAME="$(basename "$SERVER_CRT")" \
  -e LDAP_TLS_KEY_FILENAME="$(basename "$SERVER_KEY")" \
  -e LDAP_TLS_CA_CRT_FILENAME="$(basename "$CA_CRT")" \
  ldap-example

echo "OpenLDAP container 'ldap-server' started." 
