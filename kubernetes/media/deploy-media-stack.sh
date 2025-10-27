#!/bin/bash
echo "Deploying media stack..."

# Create PVCs
kubectl apply -f jellyfin-pvc.yaml
kubectl apply -f media-pvcs.yaml

# Deploy Jellyfin
kubectl apply -f jellyfin-deployment.yaml
kubectl apply -f jellyfin-service.yaml

# Deploy services
kubectl apply -f sonarr-deployment.yaml
kubectl apply -f radarr-deployment.yaml
kubectl apply -f bazarr-deployment.yaml
kubectl apply -f jackett-deployment.yaml
kubectl apply -f lidarr-deployment.yaml

# Deploy secrets and related deployment
jellyseer_secrets_file="./secrets/jellyseer-secrets.yaml"
if test -e "$jellyseer_secrets_file"; then
    echo "$jellyseer_secrets_file file exists."
    kubectl apply -f "$jellyseer_secrets_file"

    # Deploy jellyseer
    kubectl apply -f jellyseer-deployment.yaml
fi
transmission_secrets_file="./secrets/transmission-secrets.yaml"
if test -e "$transmission_secrets_file"; then
    echo "$transmission_secrets_file file exists."
    kubectl apply -f "$transmission_secrets_file"

    # Deploy transmission
    kubectl apply -f transmission-deployment.yaml
fi

# Deploy ingress

kubectl apply -f media-ingress.yaml

echo "Media stack deployed!"
echo "Access URLs:"
echo "Jellyfin: http://raspberrypi.local/jellyfin"
echo "Radarr:   http://raspberrypi.local/radarr"
echo "Sonarr:   http://raspberrypi.local/sonarr"
echo "transmission: http://raspberrypi.local/transmission"
echo "Bazarr:   http://raspberrypi.local/bazarr"
echo "Jackett:   http://raspberrypi.local/jackett"
echo "jellyseer:   http://raspberrypi.local:30008"
echo "lidarr:   http://raspberrypi.local/lidarr"