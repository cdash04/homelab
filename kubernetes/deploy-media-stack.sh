#!/bin/bash
echo "Deploying media stack..."

# Create PVCs
kubectl apply -f jellyfin-pvc.yaml
kubectl apply -f media-pvcs.yaml

# Deploy Jellyfin
kubectl apply -f jellyfin-deployment.yaml
kubectl apply -f jellyfin-service.yaml

# Deploy services
kubectl apply -f qbittorrent-deployment.yaml
kubectl apply -f sonarr-deployment.yaml
kubectl apply -f radarr-deployment.yaml
kubectl apply -f bazarr-deployment.yaml

echo "Media stack deployed!"
echo "Access URLs:"
echo "Jellyfin: http://192.168.18.12:30001"
echo "Radarr:   http://192.168.18.12:30002"
echo "Sonarr:   http://192.168.18.12:30003"
echo "qBittorrent: http://192.168.18.12:30004"
echo "Bazarr:   http://192.168.18.12:30005"