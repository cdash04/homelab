#!/bin/bash
set -e

echo "Deploying Kubernetes Dashboard stack"


# Create namespace
echo "Creating namespace"
kubectl apply -f namespace.yaml

# Create required secrets
echo "Creating required secrets..."
kubectl create secret generic kubernetes-dashboard-csrf \
  --namespace kubernetes-dashboard \
  --from-literal=csrf=$(openssl rand -base64 32) \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic kubernetes-dashboard-key-holder \
  --namespace kubernetes-dashboard \
  --from-literal=key=$(openssl rand -base64 32) \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy RBAC
echo "Deploying RBAC configuration..."
kubectl apply -f dashboard-rbac.yaml

# Wait a moment for RBAC to be ready
sleep 3

# Deploy the dashboard
echo "Deploying Kubernetes Dashboard"
kubectl apply -f dashboard-deployment.yaml

# Wait for dashboard to be ready
echo "Waiting for dashboard pods to be ready..."
if kubectl wait --for=condition=ready --timeout=180s pod -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard; then
    echo "Dashboard is ready."
else
    echo "Dashboard is taking longer than expected to start."
    echo "Checking pod status..."
    kubectl get pods -n kubernetes-dashboard
    echo "Checking pod logs..."
    kubectl logs -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard --tail=20
fi

# Deploy metrics server
echo "Deploying metrics server"
kubectl apply -f metrics-deployment.yaml

# Wait for metrics server to be ready
echo "Waiting for metrics-server pods to be ready..."
if kubectl wait --for=condition=ready --timeout=180s pod -n kube-system -l k8s-app=metrics-server; then
    echo "Metrics server is ready."
else
    echo "Dashboard is taking longer than expected to start."
    echo "Checking pod status..."
    kubectl get pods -n kube-system
    echo "Checking pod logs..."
    kubectl logs -n kube-system -l k8s-app=metrics-server --tail=20
fi

# Deploy the ingress
echo "Deploying dashboard ingress..."
kubectl apply -f dashboard-ingress.yaml

echo ""
echo "Dashboard stack deployed!"
echo ""
echo "Access via kubectl proxy:"
echo "2. Visit: http://raspberrypi.local/dashboard/"
echo ""
echo "To get access token:"
echo "kubectl -n kubernetes-dashboard create token kubernetes-dashboard"