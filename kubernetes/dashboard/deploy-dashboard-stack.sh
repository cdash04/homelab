#!/bin/bash
set -e

echo "Deploying Kubernetes Dashboard stack..."

# Create namespace
echo "Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy RBAC (needed before deployment)
echo "Deploying RBAC configuration..."
kubectl apply -f dashboard-rbac.yaml

# Wait a moment for RBAC to be ready
sleep 2

# Deploy the dashboard
echo "Deploying Kubernetes Dashboard..."
kubectl apply -f dashboard-deployment.yaml

# Wait for dashboard to be ready
echo "Waiting for dashboard pods to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/kubernetes-dashboard -n kubernetes-dashboard

# Deploy the ingress
echo "Deploying dashboard ingress..."
kubectl apply -f dashboard-ingress.yaml

# Get access information
echo ""
echo "Dashboard stack deployed!"
echo ""
echo "Access URLs:"

# Get the NodePort if using NodePort service
DASHBOARD_NODEPORT=$(kubectl get svc -n kubernetes-dashboard kubernetes-dashboard -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")

if [ "$DASHBOARD_NODEPORT" != "N/A" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || echo "raspberrypi.local")
    echo "Direct NodePort: https://${NODE_IP}:${DASHBOARD_NODEPORT}"
fi

# Get ingress host information
INGRESS_HOST=$(kubectl get ingress -n kubernetes-dashboard kubernetes-dashboard-ingress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || echo "monitor.yourdomain.com")
INGRESS_PATH=$(kubectl get ingress -n kubernetes-dashboard kubernetes-dashboard-ingress -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null || echo "/dashboard")

echo "Via Ingress: https://${INGRESS_HOST}${INGRESS_PATH}"

# Check if TLS is configured
TLS_SECRET=$(kubectl get ingress -n kubernetes-dashboard kubernetes-dashboard-ingress -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null || echo "")
if [ -n "$TLS_SECRET" ]; then
    echo "TLS: Enabled (using secret: ${TLS_SECRET})"
else
    echo "TLS: Not configured"
fi

echo ""
echo "Quick access commands:"
echo "  kubectl proxy --address='0.0.0.0' --port=8001 --accept-hosts='.*'"
echo "  Then visit: http://raspberrypi.local:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "To get access token:"
echo "  kubectl -n kubernetes-dashboard create token kubernetes-dashboard"
echo ""
echo "To view deployment status:"
echo "  kubectl get all -n kubernetes-dashboard"