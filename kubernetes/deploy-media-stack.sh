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
kubectl apply -f jackett-deployment.yaml

# Deploy secrets
secrets_file="./secrets/jellyseer-secrets.yaml"
if test -e "$secrets_file"; then
    echo "$secrets_file file exists."
    kubectl apply -f "$secrets_file"

    # Deploy jellyseer
    kubectl apply -f jellyseer-deployment.yaml
fi


echo "Media stack deployed!"
echo "Access URLs:"
echo "Jellyfin: http://raspberrypi.local:30001"
echo "Radarr:   http://raspberrypi.local:30002"
echo "Sonarr:   http://raspberrypi.local:30003"
echo "transmission: http://raspberrypi.local:30004"
echo "Bazarr:   http://raspberrypi.local:30006"
echo "Jackett:   http://raspberrypi.local:30007"
echo "jellyseer:   http://raspberrypi.local:30008"