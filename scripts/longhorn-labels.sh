#!/bin/bash

# Function to apply labels to a node
apply_labels() {
    local node=$1
    local device=$2
    
    echo "Labeling node $node with device $device"
    
    # Apply the longhornnode label
    kubectl label nodes "$node" longhornnode=true --overwrite
    
    # Apply the default-disks-config label
    kubectl label nodes "$node" \
        node.longhorn.io/default-disks-config="[{\"path\":\"$device\",\"allowScheduling\":true}]" \
        --overwrite
    
    echo "Labels applied to $node"
    echo "-------------------"
}

# Apply labels for each node
apply_labels "k8s-rancher-05" "/dev/sdb"
apply_labels "k8s-rancher-06" "/dev/sdb"
apply_labels "k8s-rancher-08" "/dev/sda"
apply_labels "k8s-rancher-09" "/dev/sda"
apply_labels "k8s-rancher-10" "/dev/nvme1n1"
apply_labels "k8s-rancher-11" "/dev/sdb"
apply_labels "k8s-rancher-12" "/dev/sdb"

echo "All nodes have been labeled for Longhorn."
