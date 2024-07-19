#!/bin/bash

# Function to check if a Kubernetes resource type exists
resource_exists() {
    kubectl api-resources --no-headers -o name | grep -q "^$1$"
    return $?
}

# Function to safely get resources
safe_get_resources() {
    local resources=()
    for resource in "$@"; do
        if resource_exists "$resource"; then
            resources+=("$resource")
        else
            echo "Resource type '$resource' does not exist in the cluster"
        fi
    done
    if [ ${#resources[@]} -gt 0 ]; then
        kubectl get "${resources[@]}" --all-namespaces
    fi
}

# Function to safely delete resources
safe_delete_resources() {
    local resources=()
    for resource in "$@"; do
        if resource_exists "$resource"; then
            resources+=("$resource")
        else
            echo "Resource type '$resource' does not exist in the cluster"
        fi
    done
    if [ ${#resources[@]} -gt 0 ]; then
        kubectl delete "${resources[@]}" --all-namespaces
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

echo "Checking for existing cert-manager resources..."
safe_get_resources "${cert_manager_resources[@]}"

read -p "Do you want to delete these resources? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting cert-manager resources..."
    safe_delete_resources "${cert_manager_resources[@]}"
fi

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