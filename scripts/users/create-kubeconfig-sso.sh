#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

# Required. Only used in the KUBECONFIG. Example: "aws-staging".
CLUSTER_NAME="${CLUSTER_NAME}"
CONTEXT_NAME="${CONTEXT_NAME:-${CLUSTER_NAME}-sso}"

# Default: AMD Okta Prod
OIDC_ISSUER_URL="${OIDC_ISSUER_URL:-https://amdsso.okta.com/oauth2/default}"
OIDC_CLIENT_ID="${OIDC_CLIENT_ID:-0oashqaa4kKos0dtZ697}"

CA_CERT="/etc/kubernetes/pki/ca.crt"
API_CERT="/etc/kubernetes/pki/apiserver.crt"
WORK_DIR="$HOME/kube-admin"
KUBECONFIG_DIR="$WORK_DIR/users/kubeconfigs"
KUBECONFIG_FILE="$KUBECONFIG_DIR/$CONTEXT_NAME.conf"

if [[ -z "${API_SERVER:-}" ]]; then
  DNS_ALL="$(openssl x509 -in "$API_CERT" -noout -text | grep "DNS:" | tr ',' '\n' | grep "DNS:" | tr -d 'DNS: ')"
  if API_DNS="$(echo "$DNS_ALL" | grep '.amazonaws.com')"; then
    : # AWS
  elif API_DNS="$(echo "$DNS_ALL" | grep '.lb.appdomain.cloud')"; then
    : # IBM
  else
    echo >&2 "DNS not found in ${API_CERT}:"
    echo >&2 "${DNS_ALL}:"
    exit 1
  fi
  # TODO: Lookup API port
  API_SERVER="https://${API_DNS}:6443"
  echo "API Server: ${API_SERVER}"
fi

# Base64 encode the certificates
CA_CERT_BASE64=$(cat "$CA_CERT" | base64 | tr -d '\n')

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
    user: oidc-login
  name: $CONTEXT_NAME
current-context: $CONTEXT_NAME
users:
- name: oidc-login
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=${OIDC_ISSUER_URL}
      - --oidc-client-id=${OIDC_CLIENT_ID}
      - --oidc-extra-scope=email,groups
      - --skip-open-browser
      env: null
      interactiveMode: Never
      provideClusterInfo: false
EOF

echo "Kubeconfig file '$KUBECONFIG_FILE' created successfully."
