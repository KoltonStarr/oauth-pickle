# TLS Utilities

This directory provides simple scripts to create a local certificate authority (CA) and to issue client and server certificates signed by that CA.

## Structure
- `ca/create-ca.sh` – generates a root CA key and self‑signed certificate. All CA artifacts remain inside the `ca` directory.
- `client-certs/generate-client-cert.sh` – generates a client key and certificate signed by the CA.
- `server-certs/generate-server-cert.sh` – generates a server key and certificate signed by the CA.

## Usage
1. **Create the CA**
   ```bash
   ./ca/create-ca.sh
   ```
2. **Generate a client certificate**
   ```bash
   ./client-certs/generate-client-cert.sh alice
   ```
3. **Generate a server certificate**
   ```bash
   ./server-certs/generate-server-cert.sh myserver
   ```
Each certificate is placed in a subdirectory named after the entity (e.g. `alice/` or `myserver/`).

