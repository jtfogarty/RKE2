This shell script saves the current configuration and then updates the StatefulSet to use a Kubernetes Secret for the API key. 

```bash
#!/bin/bash

# Set variables
NAMESPACE="typesense"
STATEFULSET_NAME="typesense"
SECRET_NAME="typesense-api-key"
BACKUP_DIR="./typesense_backup_$(date +%Y%m%d_%H%M%S)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup current configuration
echo "Backing up current configuration..."
kubectl get statefulset "$STATEFULSET_NAME" -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/statefulset_backup.yaml"
kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/secret_backup.yaml" 2>/dev/null || echo "No existing secret found."

# Extract current API key
CURRENT_API_KEY=$(kubectl get statefulset "$STATEFULSET_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].command}' | grep -oP '(?<=-a )[^ ]+')
echo "Current API Key: $CURRENT_API_KEY"

# Create or update the secret with the API key
echo "Creating/Updating secret with API key..."
kubectl create secret generic "$SECRET_NAME" --from-literal=apikey="$CURRENT_API_KEY" -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Update the StatefulSet to use the secret
echo "Updating StatefulSet to use secret..."
kubectl get statefulset "$STATEFULSET_NAME" -n "$NAMESPACE" -o json | jq '
  .spec.template.spec.containers[0].command |= map(
    if startswith("-a ") then
      "-a $(TYPESENSE_API_KEY)"
    else
      .
    end
  ) |
  .spec.template.spec.containers[0].env += [{
    "name": "TYPESENSE_API_KEY",
    "valueFrom": {
      "secretKeyRef": {
        "name": "'"$SECRET_NAME"'",
        "key": "apikey"
      }
    }
  }]
' | kubectl apply -f -

# Restart the StatefulSet to apply changes
echo "Restarting StatefulSet..."
kubectl rollout restart statefulset "$STATEFULSET_NAME" -n "$NAMESPACE"

echo "Configuration update completed. Please check the StatefulSet status to ensure it's running correctly."
echo "Backup of previous configuration saved in $BACKUP_DIR"
```

This script does the following:

1. Sets up variables for the namespace, StatefulSet name, and new secret name.
2. Creates a backup directory with a timestamp.
3. Backs up the current StatefulSet and Secret configurations.
4. Extracts the current API key from the StatefulSet configuration.
5. Creates or updates a Kubernetes Secret with the API key.
6. Updates the StatefulSet to use the secret instead of having the API key directly in the command.
7. Restarts the StatefulSet to apply the changes.

To use this script:

1. Save it to a file, e.g., `update_typesense_config.sh`
2. Make it executable: `chmod +x update_typesense_config.sh`
3. Run it: `./update_typesense_config.sh`

Before running the script, ensure that:
- You have `kubectl` configured to access your cluster.
- You have the necessary permissions to modify secrets and statefulsets in the typesense namespace.
- The `jq` command is installed on your system (it's used for JSON processing).

After running the script:
1. Verify that the StatefulSet has been updated correctly:
   ```
   kubectl get statefulset typesense -n typesense -o yaml
   ```
2. Check that the Typesense pod is running:
   ```
   kubectl get pods -n typesense
   ```
3. Test accessing Typesense to ensure it's still working with the new configuration.

This script provides a safer way to manage the API key by storing it in a Kubernetes Secret. If you need to make any adjustments or have any specific requirements, let me know, and I can help you modify the script accordingly.
