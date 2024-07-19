#!/bin/bash

# Function to safely uninstall a Helm release
safe_helm_uninstall() {
    local release=$1
    local namespace=$2

    echo "Checking for Helm release: $release in namespace: $namespace"
    if helm list -n $namespace | grep -q $release; then
        echo "Uninstalling $release..."
        helm uninstall $release -n $namespace
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to uninstall $release. It may be in an inconsistent state."
        else
            echo "$release successfully uninstalled."
        fi
    else
        echo "$release is not installed. Skipping."
    fi
}

# Function to delete kubernetes resources
delete_k8s_resources() {
    local namespace=$1
    echo "Checking for namespace: $namespace"
    if kubectl get namespace $namespace &>/dev/null; then
        echo "Deleting all resources in $namespace namespace..."
        kubectl delete all --all -n $namespace
        echo "Deleting the $namespace namespace..."
        kubectl delete namespace $namespace --timeout=60s
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to delete $namespace namespace. It may be stuck in terminating state."
        fi
    else
        echo "$namespace namespace does not exist. Skipping resource deletion."
    fi
}

echo "Starting cleanup of cert-manager and associated components..."

# Uninstall Helm releases
safe_helm_uninstall cert-manager cert-manager
safe_helm_uninstall letsencrypt-namecheap-issuer cert-manager
safe_helm_uninstall namecheap-webhook cert-manager

# Delete Kubernetes resources
delete_k8s_resources cert-manager

echo "Removing Custom Resource Definitions..."

# Remove cert-manager CRDs
echo "Attempting to remove cert-manager CRDs..."
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml
if [ $? -ne 0 ]; then
    echo "Warning: Failed to remove cert-manager CRDs. They may already be deleted."
fi

# Remove any remaining CRDs
echo "Checking for remaining cert-manager or namecheap CRDs..."
remaining_crds=$(kubectl get crd | grep -E 'cert-manager|namecheap' | awk '{print $1}')
if [ ! -z "$remaining_crds" ]; then
    echo "Removing remaining CRDs: $remaining_crds"
    kubectl delete crd $remaining_crds
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to remove some CRDs. They may be stuck in a finalizer loop."
    fi
else
    echo "No remaining cert-manager or namecheap CRDs found."
fi

echo "Verifying removal..."

# Check for any remaining cert-manager resources
if kubectl get ns | grep -q cert-manager; then
    echo "Warning: cert-manager namespace still exists"
else
    echo "cert-manager namespace successfully removed"
fi

if kubectl get crd | grep -qE 'cert-manager|namecheap'; then
    echo "Warning: Some cert-manager or namecheap CRDs still exist"
else
    echo "All cert-manager and namecheap CRDs successfully removed"
fi

echo "Cleanup process completed. Please review any warnings above."

./mclup.sh