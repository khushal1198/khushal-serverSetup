# Nginx Ingress Controller Playbooks

## Overview
This directory contains playbooks to set up and manage Nginx Ingress Controller, which solves the NodePort binding issues and provides proper external access to all Kubernetes services.

## Why Nginx Ingress Controller?
- **Solves NodePort Issues**: k3s NodePorts don't bind to external interfaces by default
- **Standard Kubernetes Way**: Proper Ingress controller for external access
- **SSL Termination**: Handle HTTPS certificates centrally
- **Path-based Routing**: Route traffic to different services based on URLs
- **Load Balancing**: Built-in load balancing capabilities

## Setup
- `setup.yml`: Installs Nginx Ingress Controller using Helm with proper NodePort configuration.

## Cleanup
- `cleanup.yml`: Removes the Nginx Ingress Controller and all related resources.

---

## Setup Instructions

1. **Install Nginx Ingress Controller:**
   ```bash
   ansible-playbook -i inventory/hosts playbooks/ingress/setup.yml
   ```

2. **Create Ingress resources for your services** (see examples below)

---

## Accessing Services

### Current Setup
- **HTTP Port**: 30080
- **HTTPS Port**: 30443
- **Server IP**: 100.110.142.150

### Access URLs (after creating Ingress resources):
- **ArgoCD**: `http://100.110.142.150:30080/argocd`
- **Grafana**: `http://100.110.142.150:30080/grafana`
- **Prometheus**: `http://100.110.142.150:30080/prometheus`
- **Kubernetes Dashboard**: `http://100.110.142.150:30080/dashboard`

---

## Creating Ingress Resources

### Example: ArgoCD Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
```

### Example: Grafana Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
spec:
  ingressClassName: nginx
  rules:
  - host: grafana.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
```

---

## What's Included

### Components:
- **Nginx Ingress Controller**: Main ingress controller
- **Load Balancer**: Built-in load balancing
- **SSL Support**: HTTPS termination capability
- **Path Routing**: Route traffic based on URLs

### Benefits:
- ✅ **No More NodePort Issues**: All services accessible via Ingress
- ✅ **Centralized Access**: Single entry point for all services
- ✅ **SSL Ready**: Easy SSL certificate management
- ✅ **Scalable**: Add new services without port conflicts

---

## Ports Used
- **30080**: HTTP traffic
- **30443**: HTTPS traffic

---

## Cleanup
To remove the Ingress Controller:
```bash
ansible-playbook -i inventory/hosts playbooks/ingress/cleanup.yml
```

---

## Troubleshooting

### Check Ingress Controller Status:
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "kubectl get pods -n ingress-nginx"
```

### Check Ingress Resources:
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "kubectl get ingress --all-namespaces"
```

### View Ingress Controller Logs:
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx"
```

---

For more details, see the [Nginx Ingress Controller documentation](https://kubernetes.github.io/ingress-nginx/). 