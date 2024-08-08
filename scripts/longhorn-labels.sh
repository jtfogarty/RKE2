#!/bin/bash

# Array of node configurations
declare -A node_configs=(
    ["k8s-rancher-05"]="/dev/sdb"
    ["k8s-rancher-06"]="/dev/sdb"
    ["k8s-rancher-08"]="/dev/sda"
    ["k8s-rancher-09"]="/dev/sda"
    ["k8s-rancher-10"]="/dev/nvme1n1"
    ["k8s-rancher-11"]="/dev/sdb"
    ["k8s-rancher-12"]="/dev/sdb"
)

# Loop through the node configurations and apply labels
for node in "${!node_configs[@]}"; do
    device="${node_configs[$node]}"
    
    echo "Labeling node $node with device $device"
    
    # Apply the longhornnode label
    kubectl label nodes "$node" longhornnode=true --overwrite
    
    # Apply the default-disks-config label
    kubectl label nodes "$node" \
        node.longhorn.io/default-disks-config="[{\"path\":\"$device\",\"allowScheduling\":true}]" \
        --overwrite
    
    echo "Labels applied to $node"
    echo "-------------------"
done

echo "All nodes have been labeled for Longhorn."
