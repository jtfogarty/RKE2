#!/bin/bash

# Array of pod details: namespace,deployment_name
pods=(
    "cattle-fleet-local-system,fleet-agent"
    "cattle-fleet-system,fleet-controller"
    "cattle-fleet-system,gitjob"
    "cattle-provisioning-capi-system,capi-controller-manager"
    "cattle-system,rancher"
    "cattle-system,rancher-webhook"
)

# Function to restart a deployment
restart_deployment() {
    local namespace=$1
    local deployment=$2
    echo "Restarting $deployment in namespace $namespace"
    kubectl rollout restart deployment $deployment -n $namespace
    kubectl rollout status deployment $deployment -n $namespace
}

# Main execution
for pod in "${pods[@]}"; do
    IFS=',' read -r namespace deployment <<< "$pod"
    restart_deployment $namespace $deployment
done
