#!/usr/bin/env bash
# Interactive TLS certificate utility
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CA_DIR="$ROOT_DIR/ca"
CLIENT_DIR="$ROOT_DIR/client-certs"
SERVER_DIR="$ROOT_DIR/server-certs"

CA_CERT="$CA_DIR/certs/ca.cert.pem"
CA_KEY="$CA_DIR/private/ca.key.pem"

# Color helpers
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
RESET="$(tput sgr0)"

check_ca() {
  if [[ ! -f "$CA_CERT" || ! -f "$CA_KEY" ]]; then
    echo "${RED}${BOLD}CA not found.${RESET}"
    echo "Run ${YELLOW}$CA_DIR/create-ca.sh${RESET} first." >&2
    exit 1
  fi
}

prompt() {
  local msg="$1"
  read -rp "$msg" ans
  echo "$ans"
}

generate_cert() {
  echo "${BOLD}Generate certificate${RESET}"
  echo "1) Server certificate"
  echo "2) Client certificate"
  local type
  type=$(prompt "Select type [1-2]: ")
  local dir ext_usage label
  case "$type" in
    1)
      dir="$SERVER_DIR"; ext_usage="serverAuth"; label="server";;
    2)
      dir="$CLIENT_DIR"; ext_usage="clientAuth"; label="client";;
    *)
      echo "Invalid selection"; return;;
  esac
  local cn org
  cn=$(prompt "Common Name (CN): ")
  [[ -z "$cn" ]] && { echo "CN is required"; return; }
  org=$(prompt "Organization (O) [optional]: ")

  mkdir -p "$dir"
  local timestamp base key csr cert tmp
  timestamp=$(date +%Y%m%d%H%M%S)
  base="${cn// /_}-$timestamp"
  key="$dir/$base.key.pem"
  csr="$dir/$base.csr.pem"
  cert="$dir/$base.cert.pem"

  tmp=$(mktemp)
  cat > "$tmp" <<EOT
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=$ext_usage
EOT

  local subj="/CN=$cn"; [ -n "$org" ] && subj+="/O=$org"
  openssl genrsa -out "$key" 2048
  openssl req -new -key "$key" -subj "$subj" -out "$csr"
  openssl x509 -req -in "$csr" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$cert" -days 365 -sha256 -extfile "$tmp"
  rm -f "$tmp" "$csr"

  echo "${GREEN}Certificate saved: $cert${RESET}"
  echo "${GREEN}Key saved: $key${RESET}"
}

validate_cert() {
  local cert
  cert=$(prompt "Path to certificate: ")
  if openssl verify -CAfile "$CA_CERT" "$cert" >/dev/null 2>&1; then
    echo "${GREEN}Certificate is valid and issued by this CA.${RESET}"
  else
    echo "${RED}Certificate NOT issued by this CA or invalid.${RESET}"
  fi
}

inspect_cert() {
  local cert
  cert=$(prompt "Path to certificate: ")
  if [[ ! -f "$cert" ]]; then
    echo "${RED}File not found${RESET}"; return
  fi
  local subject issuer from to usage cn type
  subject=$(openssl x509 -in "$cert" -noout -subject | cut -d'=' -f2-)
  issuer=$(openssl x509 -in "$cert" -noout -issuer | cut -d'=' -f2-)
  from=$(openssl x509 -in "$cert" -noout -startdate | cut -d'=' -f2)
  to=$(openssl x509 -in "$cert" -noout -enddate | cut -d'=' -f2)
  usage=$(openssl x509 -in "$cert" -noout -text | grep -A1 "Extended Key Usage" | tail -n1)
  cn=$(echo "$subject" | sed -n 's!.*/CN=\([^/]*\).*!\1!p')
  if echo "$usage" | grep -q "serverAuth"; then
    type="server certificate"
  elif echo "$usage" | grep -q "clientAuth"; then
    type="client certificate"
  else
    type="certificate"
  fi
  echo
  echo "${BOLD}Certificate details${RESET}"
  echo "This is a $type for CN=$cn issued by $issuer."
  echo "Valid from $from to $to."
}

main_menu() {
  check_ca
  while true; do
    echo
    echo "${BLUE}${BOLD}TLS Certificate Utility${RESET}"
    echo "1) Generate cert"
    echo "2) Validate cert"
    echo "3) Inspect cert"
    echo "4) Quit"
    local choice
    choice=$(prompt "> ")
    case "$choice" in
      1) generate_cert;;
      2) validate_cert;;
      3) inspect_cert;;
      4) exit 0;;
      *) echo "Invalid choice";;
    esac
  done
}

main_menu

