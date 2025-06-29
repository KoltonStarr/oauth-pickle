# oauth-pickle

**Educational reference for integrating OAuth 2.0, OpenID Connect (OIDC), LDAP, and mutual TLS (mTLS)**

This repository documents how these technologies can work together to provide a secure authentication and authorization stack. It uses real tools such as **Keycloak** (an open source identity provider) and **OpenLDAP** (a directory service) and demonstrates deployments in **Kubernetes**.

## Concepts

- **OAuth 2.0** – industry standard authorization framework used to securely grant access without sharing credentials.
- **OpenID Connect (OIDC)** – authentication layer built on top of OAuth 2.0 that provides identity information using ID tokens.
- **LDAP** – directory protocol typically used to store user accounts and group membership.
- **mTLS** – mutual TLS where both client and server validate certificates to establish a trusted connection.

These pieces combine to create a robust single sign‑on system with strong client authentication.

## Key Technologies

- **Keycloak** – acts as the OIDC and OAuth 2.0 provider. Keycloak can authenticate users against LDAP and issue tokens for applications.
- **OpenLDAP** – stores user accounts and groups. Keycloak can be configured to synchronize user data from LDAP.
- **Kubernetes (K8s)** – orchestrates container deployments. The examples here show Keycloak and dependent services running on a cluster.

## Example Architecture

1. Users exist in an OpenLDAP directory.
2. Keycloak is configured with an LDAP user federation provider. When users authenticate to Keycloak, it queries LDAP for credentials and profile data.
3. Applications perform OAuth 2.0 or OIDC flows with Keycloak to obtain access tokens and ID tokens.
4. All communication between the applications and Keycloak uses mTLS so both parties verify each other's certificates.

```
[User] ---> mTLS ---> [Keycloak] ---> LDAP queries ---> [OpenLDAP]
                        |
                        | OAuth 2.0 / OIDC tokens
                        v
                   [Application]
```

## Getting Started

The following steps outline one possible setup in a lab environment using Docker images.

### 1. Run OpenLDAP and Keycloak

```bash
# example docker compose snippet
version: '3'
services:
  ldap:
    image: osixia/openldap:1.5.0
    ports:
      - "389:389"
    environment:
      LDAP_ORGANISATION: "Example"
      LDAP_DOMAIN: "example.org"

  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: start-dev
    ports:
      - "8443:8443"
    environment:
      KC_DB: h2
      KC_HOSTNAME: localhost
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
```

Keycloak supports LDAP user federation which can be enabled via the admin console or CLI. Configure it to point at the `ldap` service.

### 2. Enable mTLS

Keycloak can be run with HTTPS enabled using your own certificates. For lab setups you can generate a certificate authority (CA) and sign client certificates. Configure the Keycloak proxy to require client certificates.

```
keytool -genkeypair -alias keycloak -keyalg RSA -keystore keycloak.jks -storepass changeit
```

Applications then need to present their client certificate when talking to Keycloak over HTTPS.

### 3. Use OAuth 2.0 / OIDC from an Application

Applications redirect users to Keycloak for login. After successful authentication, Keycloak issues tokens which the application can verify. The user credentials are validated against LDAP, but the application only deals with tokens.

## Kubernetes Example

You can deploy the same setup on a Kubernetes cluster. Below is a simplified example using cert-manager for certificates:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: keycloak-tls
spec:
  secretName: keycloak-tls
  dnsNames:
    - keycloak.example.org
  issuerRef:
    name: ca-issuer
    kind: Issuer
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
        - name: keycloak
          image: quay.io/keycloak/keycloak:latest
          args: ['start-dev']
          env:
            - name: KEYCLOAK_ADMIN
              value: admin
            - name: KEYCLOAK_ADMIN_PASSWORD
              value: admin
          volumeMounts:
            - name: tls
              mountPath: /etc/x509/https
      volumes:
        - name: tls
          secret:
            secretName: keycloak-tls
```

In this example, Keycloak uses a TLS certificate provided by cert-manager. You can configure an `nginx` ingress controller to enforce mTLS for incoming requests and to route traffic to Keycloak.

## Further Reading

- [Keycloak documentation](https://www.keycloak.org/documentation) – covers configuring LDAP user federation and securing endpoints with mTLS.
- [OpenLDAP](https://www.openldap.org/doc/) – details on running and administering the directory server.
- [OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc6749) and [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) specifications.
- [Kubernetes documentation](https://kubernetes.io/docs/home/) – information on deploying containers and managing certificates with cert-manager.

This project aims to serve as a concise reference that shows how these components fit together in practice.
