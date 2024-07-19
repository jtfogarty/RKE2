#!/bin/bash

# Function to check if a command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Check for required environment variables
if [ -z "$NAMECHEAP_API_KEY" ] || [ -z "$NAMECHEAP_USERNAME" ] || [ -z "$ACME_EMAIL" ] || [ -z "$DOMAIN_NAME" ]; then
    echo "Error: Missing required environment variables. Please set NAMECHEAP_API_KEY, NAMECHEAP_USERNAME, ACME_EMAIL, and DOMAIN_NAME."
    exit 1
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is not installed. Please install Helm and try again."
    exit 1
fi

# Add cert-manager Helm repository
echo "Adding cert-manager Helm repository..."
helm repo add jetstack https://charts.jetstack.io
check_command "Failed to add cert-manager Helm repository"

helm repo update
check_command "Failed to update Helm repositories"

# Install or upgrade cert-manager using Helm
echo "Installing/upgrading cert-manager..."
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true \
  --set "extraArgs={--feature-gates=ServerSideApply=true}"
check_command "Failed to install/upgrade cert-manager"

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s
check_command "cert-manager deployment timed out"

# Remove existing ClusterRole and ClusterRoleBinding
echo "Removing existing ClusterRole and ClusterRoleBinding..."
kubectl delete clusterrole cert-manager-webhook-namecheap --ignore-not-found
kubectl delete clusterrolebinding cert-manager-webhook-namecheap --ignore-not-found

# Create ClusterRole for cert-manager
echo "Creating ClusterRole for cert-manager..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cert-manager-webhook-namecheap
  labels:
    app.kubernetes.io/managed-by: Helm
  annotations:
    meta.helm.sh/release-name: cert-manager-webhook-namecheap
    meta.helm.sh/release-namespace: cert-manager
rules:
- apiGroups:
  - "acme.namecheap.com"
  resources:
  - "*"
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - delete
EOF
check_command "Failed to create ClusterRole"

# Create ClusterRoleBinding
echo "Creating ClusterRoleBinding..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cert-manager-webhook-namecheap
  labels:
    app.kubernetes.io/managed-by: Helm
  annotations:
    meta.helm.sh/release-name: cert-manager-webhook-namecheap
    meta.helm.sh/release-namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-webhook-namecheap
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
EOF
check_command "Failed to create ClusterRoleBinding"

# Check if the cert-manager-webhook-namecheap directory exists
if [ -d "cert-manager-webhook-namecheap" ]; then
    echo "cert-manager-webhook-namecheap directory already exists. Updating..."
    cd cert-manager-webhook-namecheap
    git pull || check_command "Failed to update cert-manager-webhook-namecheap repository"
    cd ..
else
    echo "Cloning cert-manager-webhook-namecheap..."
    git clone https://github.com/kelvie/cert-manager-webhook-namecheap.git || check_command "Failed to clone cert-manager-webhook-namecheap repository"
fi

# Install or upgrade Namecheap webhook
echo "Installing/upgrading Namecheap webhook..."
helm upgrade --install cert-manager-webhook-namecheap --namespace cert-manager ./cert-manager-webhook-namecheap/deploy/cert-manager-webhook-namecheap
check_command "Failed to install/upgrade Namecheap webhook"

# Create or update Namecheap API credentials secret
echo "Creating/updating Namecheap API credentials secret..."
kubectl create secret generic namecheap-api-key \
    --from-literal=api-key="${NAMECHEAP_API_KEY}" \
    --from-literal=api-user="${NAMECHEAP_USERNAME}" \
    -n cert-manager \
    --dry-run=client -o yaml | kubectl apply -f -
check_command "Failed to create/update Namecheap API key secret"

# Create or update ClusterIssuer
echo "Creating/updating ClusterIssuer..."
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${ACME_EMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-issuer-account-key
    solvers:
    - dns01:
        webhook:
          groupName: acme.namecheap.com
          solverName: namecheap
          config:
            apiKeySecretRef:
              name: namecheap-api-key
              key: api-key
            apiUserSecretRef:
              name: namecheap-api-key
              key: api-user
EOF
check_command "Failed to create/update ClusterIssuer"

# Generate or update certificate
echo "Generating/updating certificate..."
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${DOMAIN_NAME/./-}-tls
  namespace: default
spec:
  secretName: ${DOMAIN_NAME/./-}-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - ${DOMAIN_NAME%%.*}
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - ${DOMAIN_NAME}
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
    group: cert-manager.io
EOF
check_command "Failed to create/update Certificate"

echo "Setup completed successfully!"
echo "You can check the status of your certificate with:"
echo "kubectl get certificate -n default ${DOMAIN_NAME/./-}-tls"