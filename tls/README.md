# TLS Utilities

This directory provides scripts to create a local certificate authority (CA) and interactively issue client or server certificates signed by that CA.

## Structure
- `ca/create-ca.sh` – generates a root CA key and self‑signed certificate.
- `cert-cli.sh` – interactive tool for creating, validating and inspecting certificates.
- `client-certs/` – storage location for generated client certificates.
- `server-certs/` – storage location for generated server certificates.

## Usage
1. **Create the CA**
   ```bash
   ./ca/create-ca.sh
   ```
2. **Run the certificate utility**
   ```bash
   ./cert-cli.sh
   ```
   Follow the prompts to generate a client or server certificate, validate an existing certificate, or inspect its contents.

Certificates and keys will be placed directly in `client-certs/` or `server-certs/` using unique filenames for easy organization.

