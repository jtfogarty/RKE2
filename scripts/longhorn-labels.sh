#!/bin/bash

# Function to apply labels to a node
apply_labels() {
    local node=$1
    local device=$2
    
    echo "Labeling node $node with device $device"
    
    # Remove the old incorrect label if it exists
    kubectl label nodes "$node" longhornnode- --ignore-not-found

    # Apply the correct longhorn-node label
    kubectl label nodes "$node" longhorn-node=true --overwrite
    
    # Apply the create-default-disk label
    kubectl label nodes "$node" node.longhorn.io/create-default-disk=true --overwrite
    
    # Apply the specific disk config label
    kubectl label nodes "$node" \
        node.longhorn.io/default-disk-$device=true \
        --overwrite
    
    echo "Labels applied to $node"
    echo "-------------------"
}

# Apply labels for each node
apply_labels "k8s-rancher-05" "sdb"
apply_labels "k8s-rancher-06" "sdb"
apply_labels "k8s-rancher-08" "sda"
apply_labels "k8s-rancher-09" "sda"
apply_labels "k8s-rancher-10" "nvme1n1"
apply_labels "k8s-rancher-11" "sdb"
apply_labels "k8s-rancher-12" "sdb"

echo "All nodes have been labeled for Longhorn."
