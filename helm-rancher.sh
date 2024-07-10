# Add the Rancher Helm repository
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

# Create a namespace for Rancher
kubectl create namespace cattle-system

# Install cert-manager (required for Rancher)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0

# Wait for cert-manager to be ready
kubectl get pods --namespace cert-manager

# Install Rancher
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set bootstrapPassword=admin

# Wait for Rancher to be ready
kubectl -n cattle-system rollout status deploy/rancher

# Check the status of the Rancher pod
kubectl -n cattle-system get pods