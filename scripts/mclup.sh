#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if a Kubernetes resource type exists
resource_exists() {
    kubectl api-resources --verbs=list --namespaced -o name | grep -q "^$1$"
    return $?
}

# Function to safely get resources
safe_get_resources() {
    local existing_resources=()
    for resource in "$@"; do
        if resource_exists "$resource"; then
            existing_resources+=("$resource")
        else
            echo "Warning: Resource type '$resource' does not exist in the cluster"
        fi
    done
    if [ ${#existing_resources[@]} -gt 0 ]; then
        kubectl get "${existing_resources[@]}" --all-namespaces
    else
        echo "No valid resources to get"
    fi
}

# Function to safely delete resources
safe_delete_resources() {
    local existing_resources=()
    for resource in "$@"; do
        if resource_exists "$resource"; then
            existing_resources+=("$resource")
        else
            echo "Warning: Resource type '$resource' does not exist in the cluster"
        fi
    done
    if [ ${#existing_resources[@]} -gt 0 ]; then
        kubectl delete "${existing_resources[@]}" --all-namespaces
    else
        echo "No valid resources to delete"
    fi
}

# List of cert-manager resource types to check
cert_manager_resources=(
    "issuers"
    "clusterissuers"
    "certificates"
    "certificaterequests"
    "orders"
    "challenges"
)

# Main script execution
main() {
    check_kubectl

    echo "Checking for existing cert-manager resources..."
    safe_get_resources "${cert_manager_resources[@]}"

    read -p "Do you want to delete these resources? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting cert-manager resources..."
        safe_delete_resources "${cert_manager_resources[@]}"
    fi

    # ... (rest of the script remains unchanged)
}

# Run the main function
main

echo "Checking for cert-manager CRDs..."
cert_manager_crds=$(kubectl get crd -o name | grep cert-manager)

if [ -n "$cert_manager_crds" ]; then
    echo "Found the following cert-manager CRDs:"
    echo "$cert_manager_crds"

    read -p "Do you want to remove finalizers and delete these CRDs? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing finalizers and deleting cert-manager CRDs..."
        echo "$cert_manager_crds" | while read -r crd; do
            kubectl patch "$crd" -p '{"metadata":{"finalizers":[]}}' --type=merge
            kubectl delete "$crd" --timeout=30s
        done
    fi
else
    echo "No cert-manager CRDs found."
fi

echo "Checking for cert-manager ClusterRoles and ClusterRoleBindings..."
cert_manager_cluster_resources=$(kubectl get clusterroles,clusterrolebindings --no-headers | grep cert-manager | awk '{print $1}')

if [ -n "$cert_manager_cluster_resources" ]; then
    echo "Found the following cert-manager cluster resources:"
    echo "$cert_manager_cluster_resources"

    read -p "Do you want to delete these cluster resources? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting cert-manager cluster resources..."
        echo "$cert_manager_cluster_resources" | while read -r resource; do
            kubectl delete "$resource"
        done
    fi
else
    echo "No cert-manager cluster resources found."
fi

echo "Checking cert-manager namespace..."
if kubectl get namespace cert-manager &>/dev/null; then
    echo "cert-manager namespace exists."

    read -p "Do you want to delete the cert-manager namespace? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting cert-manager namespace..."
        kubectl delete namespace cert-manager --timeout=60s
        if kubectl get namespace cert-manager &>/dev/null; then
            echo "Namespace is stuck, attempting to remove finalizers..."
            kubectl get namespace cert-manager -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/cert-manager/finalize" -f -
        fi
    fi
else
    echo "cert-manager namespace does not exist."
fi

echo "Script completed."
