#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USER_NAME=$1

sudo kubectl apply --kubeconfig /etc/kubernetes/admin.conf -f- <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-binding-kisenber
subjects:
- kind: User
  name: "${USER_NAME}"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
