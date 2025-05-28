#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

USER_NAME="${1:-$USER_NAME}"
CERT_DIR="$HOME/kube-admin/users/certs"

mkdir -p "$CERT_DIR"

# Generate the private key
openssl genpkey -algorithm ED25519 -out "$CERT_DIR/$USER_NAME.key"

# Generate the certificate signing request (CSR)
openssl req -new -key "$CERT_DIR/$USER_NAME.key" -out "$CERT_DIR/$USER_NAME.csr" -subj "/CN=$USER_NAME/O=amd"

# Sign the CSR with the CA certificate to generate the certificate
sudo openssl x509 -req -in "$CERT_DIR/$USER_NAME.csr" -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out "$CERT_DIR/$USER_NAME.crt" -days 365

echo "Certificates for user '$USER_NAME' have been created in '$CERT_DIR'."
