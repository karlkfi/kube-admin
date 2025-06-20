# User Management

These scripts are for managing Kubernetes users.

This assumes SSO is not configured and users exist only in this cluster.

1. Select a user name:
    ```bash
    export USER_NAME=example
    ```
1. Select a cluster name:
    ```bash
    export CLUSTER_NAME=aws-test
    ```
1. Create a new user key pair and sign the crt with the Kubernetes cluster Root CA:
    ```bash
    ./scripts/users/create-certs.sh
    ```
    Certs generated:
    - `~/kube-admin/users/certs/$USER_NAME.key` - private key
    - `~/kube-admin/users/certs/$USER_NAME.csr` - certificate signing request
    - `~/kube-admin/users/certs/$USER_NAME.crt` - signed public key
1. Create a kubeconfig for a user:
    ```bash
    ./scripts/users/create-kubeconfig.sh
    ```
    Config generated: `~/kube-admin/users/kubeconfigs/$USER_NAME.conf`
1. Grant the user `cluster-admin`:
    ```bash
    ./scripts/users/grant-cluster-admin.sh
    ```
    ClusterRoleBinding will be applied directly to the cluster using `kubectl` and the `/etc/kubernetes/admin.conf` credentials.
