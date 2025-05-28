#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1
CERT_DIR=~/kube-admin/users/certs

mkdir -p "$CERT_DIR"

# Generate the private key
openssl genpkey -algorithm ED25519 -out "$CERT_DIR/$USERNAME.key"

# Generate the certificate signing request (CSR)
openssl req -new -key "$CERT_DIR/$USERNAME.key" -out "$CERT_DIR/$USERNAME.csr" -subj "/CN=$USERNAME/O=amd"

# Sign the CSR with the CA certificate to generate the certificate
sudo openssl x509 -req -in "$CERT_DIR/$USERNAME.csr" -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out "$CERT_DIR/$USERNAME.crt" -days 365

echo "Certificates for user '$USERNAME' have been created in '$CERT_DIR'."
