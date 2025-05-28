# User Management

These scripts are for managing Kubernetes users.

This assumes SSO is not configured and users exist only in this cluster.

1. Create a new user key pair and sign it withe the Kubernetes cluster Root CA:
    ```
    ./create-certs.sh $USERNAME
    ```
    Certs generated:
    - `~/kube-admin/certs/$USERNAME.key` - private key
    - `~/kube-admin/certs/$USERNAME.csr` - certificate signing request
    - `~/kube-admin/certs/$USERNAME.crt` - signed public key
1. Create a kubeconfig for a user:
    ```
    ./create-kubeconfig.sh $USERNAME
    ```
    Config generated: `~/kube-admin/kubeconfigs/$USERNAME.conf`
1. Grant the user `cluster-admin`:
    ```
    ./grant-cluster-admin.sh $USERNAME
    ```
    ClusterRoleBinding will be applied directly to the cluster using `kubectl` and the `/etc/kubernetes/admin.conf` credentials.
