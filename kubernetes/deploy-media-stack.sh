#!/bin/bash
echo "Deploying media stack..."

# Create PVCs
kubectl apply -f jellyfin-pvc.yaml
kubectl apply -f media-pvcs.yaml

# Deploy Jellyfin
kubectl apply -f jellyfin-deployment.yaml
kubectl apply -f jellyfin-service.yaml

# Deploy services
kubectl apply -f transmission-deployment.yaml
kubectl apply -f sonarr-deployment.yaml
kubectl apply -f radarr-deployment.yaml
kubectl apply -f bazarr-deployment.yaml

echo "Media stack deployed!"
echo "Access URLs:"
echo "Jellyfin: http://raspberrypi.local:30001"
echo "Radarr:   http://raspberrypi.local:30002"
echo "Sonarr:   http://raspberrypi.local:30003"
echo "transmission: http://raspberrypi.local:30004"
echo "Bazarr:   http://raspberrypi.local:30006"