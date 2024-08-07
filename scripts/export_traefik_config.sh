#!/bin/bash

# Function to export resource data
export_resource() {
    local resource=$1
    local namespace=$2
    local output_file=$3
    
    echo "Exporting $resource from namespace $namespace" >> "$output_file"
    kubectl get "$resource" -n "$namespace" -o yaml >> "$output_file"
    echo "---" >> "$output_file"
}

# Create output file
output_file="traefik_export_$(date +%Y%m%d_%H%M%S).yaml"
echo "Traefik Configuration Export" > "$output_file"
echo "Date: $(date)" >> "$output_file"
echo "---" >> "$output_file"

# Export Traefik resources
export_resource "deployment" "traefik" "$output_file"
export_resource "service" "traefik" "$output_file"
export_resource "configmap" "traefik" "$output_file"
export_resource "secret" "traefik" "$output_file"

# Export IngressRoutes (Traefik CRDs)
echo "Exporting IngressRoutes from all namespaces" >> "$output_file"
kubectl get ingressroutes.traefik.containo.us --all-namespaces -o yaml >> "$output_file"
echo "---" >> "$output_file"

# Export standard Ingress resources
echo "Exporting Ingress resources from all namespaces" >> "$output_file"
kubectl get ingress --all-namespaces -o yaml >> "$output_file"
echo "---" >> "$output_file"

# Export Traefik CRDs
echo "Exporting Traefik CRDs" >> "$output_file"
kubectl get crd | grep traefik | awk '{print $1}' | while read crd; do
    kubectl get crd "$crd" -o yaml >> "$output_file"
    echo "---" >> "$output_file"
done

# Export node information
echo "Exporting Node information" >> "$output_file"
kubectl get nodes -o yaml >> "$output_file"
echo "---" >> "$output_file"

# Export Traefik logs
echo "Exporting Traefik logs" >> "$output_file"
kubectl logs -n traefik -l app.kubernetes.io/name=rke2-traefik --tail=1000 >> "$output_file"

echo "Export completed. File saved as $output_file"
