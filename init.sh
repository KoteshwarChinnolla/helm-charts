#!/bin/bash

set -e

echo "Choose kubernetes cluster type: 1. KIND 2. EKS"
read -p "Enter your choice (1 or 2): " choice

if [ $choice -eq 1 ]; then
  kind create cluster --config kind-config.yaml --name hrms-kind-cluster
else 
  aws eks update-kubeconfig --region ap-south-1 --name hrms_eks_cluster
fi

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

isthioctl version &> /dev/null || istioctl install --set profile=demo -y

# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=hrms.anasolconsultencyservices.com/O=hrms.anasolconsultencyservices.com"

# kubectl create secret tls tls-secret --key tls.key --cert tls.crt

kubectl create namespace hrms

# kubectl label namespace hrms istio-injection=enabled

kubectl create namespace isthio-gateway

helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.15.0 --set installCRDs=true

