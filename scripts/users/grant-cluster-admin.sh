#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

USER_NAME="${1:-$USER_NAME}"

sudo kubectl apply --kubeconfig /etc/kubernetes/admin.conf -f- <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: "admin-binding-${USER_NAME}"
subjects:
- kind: User
  name: "${USER_NAME}"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
