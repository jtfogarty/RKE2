# Scripts

This directory contains scripts for managing cert-manager and related components in a Kubernetes cluster.

## cleanup-cert-manager.sh

This script is designed to clean up cert-manager and its associated components from a Kubernetes cluster.

### How it works:

1. Safely uninstalls Helm releases related to cert-manager.
2. Deletes Kubernetes resources in the cert-manager namespace.
3. Removes Custom Resource Definitions (CRDs) associated with cert-manager.
4. Verifies the removal of cert-manager components.

### Usage:

```bash
./cleanup-cert-manager.sh
```

No environment variables are required for this script.

## install-cert-mgr.sh

This script installs and configures cert-manager with Namecheap DNS validation for Let's Encrypt certificates.

### How it works:

1. Checks for required environment variables and Helm installation.
2. Adds the cert-manager Helm repository.
3. Installs or upgrades cert-manager using Helm.
4. Creates necessary RBAC resources (ClusterRole and ClusterRoleBinding).
5. Installs the Namecheap webhook for DNS validation.
6. Creates a secret for Namecheap API credentials.
7. Sets up a ClusterIssuer for Let's Encrypt.
8. Generates a certificate for the specified domain.

### Required Environment Variables:

- `NAMECHEAP_API_KEY`: Your Namecheap API key
- `NAMECHEAP_USERNAME`: Your Namecheap username
- `ACME_EMAIL`: Email address for Let's Encrypt account
- `DOMAIN_NAME`: Domain name for which to generate the certificate

### Usage:

```bash
export NAMECHEAP_API_KEY=your_api_key
export NAMECHEAP_USERNAME=your_username
export ACME_EMAIL=your_email@example.com
export DOMAIN_NAME=your_domain.com
./install-cert-mgr.sh
```

Make sure to set the required environment variables before running the script.

## Note:

Both scripts require `kubectl` to be configured with the appropriate cluster context. The `install-cert-mgr.sh` script also requires `helm` to be installed and configured.
