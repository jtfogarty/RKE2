#!/bin/bash

# Set variables
LOCAL_OUTPUT_DIR="./disk_info_output"
COMBINED_FILE="$LOCAL_OUTPUT_DIR/disk_info_all_hosts.json"

# Ensure the output directory exists
mkdir -p "$LOCAL_OUTPUT_DIR"

# Initialize the combined JSON array
echo "[" > "$COMBINED_FILE"

# Find all disk info files and combine them
first_file=true
for file in "$LOCAL_OUTPUT_DIR"/*_disk_info.json; do
    if [ -f "$file" ]; then
        if [ "$first_file" = true ]; then
            first_file=false
        else
            echo "," >> "$COMBINED_FILE"
        fi
        cat "$file" >> "$COMBINED_FILE"
    fi
done

# Close the JSON array
echo "]" >> "$COMBINED_FILE"

echo "Combined disk information for all hosts has been saved to $COMBINED_FILE"

# Optional: Create a summary
echo "Summary of disk information:" > "$LOCAL_OUTPUT_DIR/summary.txt"
jq -r '.[] | "Host: \(.hostname)\nTotal devices: \(.total_devices)\nOS device: \(.os_device)\nDevices: \(.devices | join(", "))\n"' "$COMBINED_FILE" >> "$LOCAL_OUTPUT_DIR/summary.txt"

echo "Summary has been saved to $LOCAL_OUTPUT_DIR/summary.txt"