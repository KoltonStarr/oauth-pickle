#!/usr/bin/env bash
# Create a user entry in the running LDAP server.
# Usage: create-user.sh <uid> <first-name> <last-name> <password>
# Example: ./create-user.sh jdoe John Doe s3cr3t

set -e

if [ $# -ne 4 ]; then
  echo "Usage: $0 <uid> <first-name> <last-name> <password>"
  exit 1
fi

UID="$1"
GIVEN_NAME="$2"
LAST_NAME="$3"
PASSWORD="$4"

# Generate LDIF content for the new user.
# inetOrgPerson is a common object class for user accounts.
LDIF="dn: uid=${UID},ou=people,dc=example,dc=org
objectClass: inetOrgPerson
uid: ${UID}
cn: ${GIVEN_NAME} ${LAST_NAME}
givenName: ${GIVEN_NAME}
sn: ${LAST_NAME}
userPassword: ${PASSWORD}
"

# Pass the LDIF to ldapadd running inside the container.
echo "$LDIF" | docker exec -i ldap-server ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -H ldaps://localhost

echo "User '${UID}' added."

