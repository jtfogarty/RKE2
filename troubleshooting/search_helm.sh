#!/bin/bash

# Check if a search string was provided
if [ $# -eq 0 ]; then
    echo "Please provide a search string"
    echo "Usage: $0 <search-string>"
    exit 1
fi

search_string="$1"

# Get all Rancher-related Helm releases
rancher_releases=$(helm list --all-namespaces | grep rancher)

# Check if any Rancher releases were found
if [ -z "$rancher_releases" ]; then
    echo "No Rancher releases found"
    exit 0
fi

# Function to search values for a release
search_release_values() {
    local release="$1"
    local namespace="$2"
    local search="$3"
    
    echo "Searching in release: $release (Namespace: $namespace)"
    result=$(helm get values "$release" -n "$namespace" | grep -i "$search")
    
    if [ -n "$result" ]; then
        echo "Found match:"
        echo "$result"
    else
        echo "No match found"
    fi
    echo "-----------------------------------"
}

# Process each Rancher release
echo "$rancher_releases" | while read -r line; do
    # Extract release name and namespace
    release_name=$(echo "$line" | awk '{print $1}')
    namespace=$(echo "$line" | awk '{print $2}')
    
    # Search values for this release
    search_release_values "$release_name" "$namespace" "$search_string"
done