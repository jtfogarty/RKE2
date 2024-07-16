#!/bin/bash

# Check if a search string is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <search_string>"
    echo "Use 'ALL' to get all log records from the past hour"
    exit 1
fi

SEARCH_STRING="$1"
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S")
ONE_HOUR_AGO=$(date -u -d '1 hour ago' +"%Y-%m-%dT%H:%M:%S")

# Function to check if a log line is within the last hour
is_within_last_hour() {
    local log_time="$1"
    if [[ "$log_time" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ ([0-9]{2}:){2}[0-9]{2} ]]; then
        log_time=$(date -u -d "$log_time" +"%Y-%m-%dT%H:%M:%S")
    fi
    if [[ "$log_time" > "$ONE_HOUR_AGO" && "$log_time" < "$CURRENT_TIME" ]]; then
        return 0
    else
        return 1
    fi
}

# Get all pods in the kube-system namespace
pods=$(kubectl get pods -n kube-system -o jsonpath='{.items[*].metadata.name}')

# Loop through each pod
for pod in $pods; do
    echo "Searching logs for pod: $pod"

    # Get logs from the past hour
    logs=$(kubectl logs --since=1h $pod -n kube-system)

    # Process each log line
    while IFS= read -r line; do
        timestamp=$(echo "$line" | awk '{print $1, $2}')
        if is_within_last_hour "$timestamp"; then
            if [[ "$SEARCH_STRING" == "ALL" ]] || [[ "$line" == *"$SEARCH_STRING"* ]]; then
                echo "$pod: $line"
            fi
        fi
    done <<< "$logs"

    echo ""  # Empty line for better readability
done
~
~