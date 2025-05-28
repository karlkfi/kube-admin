#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USER_NAME="${USER_NAME:-$1}"
CLUSTER_NAME="${CLUSTER_NAME:-aws-test}"
CONTEXT_NAME="${CONTEXT_NAME:-aws-test}"

CA_CERT="/etc/kubernetes/pki/ca.crt"
API_CERT="/etc/kubernetes/pki/apiserver.crt"
WORK_DIR="$HOME/kube-admin"
CRT_DIR="$WORK_DIR/users/certs"
CLIENT_CERT="$CRT_DIR/$USER_NAME.crt"
CLIENT_KEY="$CRT_DIR/$USER_NAME.key"
KUBECONFIG_DIR="$WORK_DIR/users/kubeconfigs"
KUBECONFIG_FILE="$KUBECONFIG_DIR/$USER_NAME.conf"

if [[ -z "${API_SERVER:-}" ]]; then
  DNS_ALL="$(openssl x509 -in "$API_CERT" -noout -text | grep "DNS:" | tr ',' '\n' | grep "DNS:" | tr -d 'DNS: ')"
  DNS_NLB="$(echo "$DNS_ALL" | grep '.amazonaws.com')"
  API_SERVER="https://${DNS_NLB}:6443"
fi

# Base64 encode the certificates
CA_CERT_BASE64=$(cat "$CA_CERT" | base64 | tr -d '\n')
CLIENT_CERT_BASE64=$(cat "$CLIENT_CERT" | base64 | tr -d '\n')
CLIENT_KEY_BASE64=$(cat "$CLIENT_KEY" | base64 | tr -d '\n')

mkdir -p "$KUBECONFIG_DIR"

# Create Kubeconfig file with embedded certificates
cat <<EOF > "$KUBECONFIG_FILE"
apiVersion: v1
clusters:
- cluster:
    server: $API_SERVER
    certificate-authority-data: $CA_CERT_BASE64
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $USER_NAME
  name: $CONTEXT_NAME
current-context: $CONTEXT_NAME
users:
- name: $USER_NAME
  user:
    client-certificate-data: $CLIENT_CERT_BASE64
    client-key-data: $CLIENT_KEY_BASE64
EOF

echo "Kubeconfig file '$KUBECONFIG_FILE' created successfully with embedded certificates."
