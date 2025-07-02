# Local LLDAP Server

This directory contains a minimal setup for running [lldap](https://github.com/lldap/lldap)
on your local machine using Docker Compose. It relies on the TLS utilities in
`../tls` to generate an internal certificate authority (CA) and a server
certificate for lldap.

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) and `docker compose` installed.
- Bash shell utilities available.

## Setup
1. **Create the internal CA and server certificate**
   ```bash
   # from the repository root
   ./tls/ca/create-ca.sh
   ./tls/server-certs/generate-server-cert.sh lldap
   # copy or link the generated certificate
   mkdir -p ldap/certs
   cp tls/server-certs/lldap/lldap.cert.pem ldap/certs/
   cp tls/server-certs/lldap/lldap.key.pem ldap/certs/
   ```

2. **Generate application secrets**
   ```bash
   cd ldap
   ./generate_secrets.sh
   ```
   This creates the files under `ldap/secrets/` used by the container.

3. **Start the server**
   ```bash
   docker compose up -d
   ```
   The web UI will be available on [https://localhost:17170](https://localhost:17170)
   and LDAPS on port `6360`.

The default admin password is written to `secrets/admin_pass` by the
`generate_secrets.sh` script. Edit that file to change it before starting the
service.

## Trusting the Internal CA
To trust the server certificate, import `tls/ca/certs/ca.cert.pem` into your
system or application's trusted certificate store. The lldap container uses the
certificate generated in step 1, which is signed by this CA.

## Cleaning Up
To stop and remove the container:
```bash
docker compose down
```
Remove the `data`, `secrets`, and `certs` directories if you want to start from
scratch.
