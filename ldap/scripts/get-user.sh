#!/usr/bin/env bash
# Retrieve a user entry from the running LDAP server.
# Usage: get-user.sh <uid>

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <uid>"
  exit 1
fi

UID="$1"

docker exec ldap-server ldapsearch -x -LLL -b "dc=example,dc=org" "uid=${UID}"


