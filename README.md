# Server Setup with Ansible

This repository contains Ansible playbooks and roles for setting up and managing a complete Kubernetes-based server infrastructure with CI/CD, monitoring, and security tools.

## 🚀 Quick Start

### Prerequisites
- **Ansible 2.9+** and **Python 3.6+**
- **SSH access** to target server with sudo privileges
- **k3s** already installed on the target server
- **Helm** installed on the target server

### One-Command Deployment
```bash
# Complete setup (recommended)
ansible-playbook -i inventory/hosts playbooks/deploy-all.yml

# Or step-by-step (see Installation Order below)
```

### Complete Cleanup
```bash
# Remove everything and start fresh
ansible-playbook -i inventory/hosts playbooks/cleanup-all.yml
```

---

## 📋 Installation Order

The deployment follows this logical order to ensure dependencies are met:

1. **Basic Server Setup** - Packages, firewall, security
2. **Nginx Ingress Controller** - External access layer
3. **Monitoring Stack** - Prometheus & Grafana
4. **Kubernetes Dashboard** - Cluster management UI
5. **ArgoCD** - GitOps CI/CD
6. **HashiCorp Vault** - Secrets management
7. **Jenkins** - CI/CD pipelines
8. **Ingress Resources** - Service routing

---

## 🌐 Access URLs

After deployment, access your services at:

### Via Ingress Controller (Recommended)
- **ArgoCD**: `http://<HOST>:30080/argocd`
- **Grafana**: `http://<HOST>:30080/grafana`
- **Prometheus**: `http://<HOST>:30080/prometheus`
- **Kubernetes Dashboard**: `http://<HOST>:30080/dashboard`
- **Jenkins**: `http://<HOST>:30080/jenkins/`

### Direct Access (NodePort)
- **Kubernetes Dashboard**: `https://<HOST>:31000` *(Note: Uses HTTPS with self-signed cert)*
- **Jenkins**: `http://<HOST>:30000`
- **Vault**: `http://<HOST>:30201`

### Dashboard Access Note
The Kubernetes Dashboard is served directly via NodePort (port 31000) because it doesn't support subpath routing through ingress controllers. You'll need to accept the self-signed certificate warning in your browser.

---

## 🔧 Individual Playbooks

### Master Playbooks
- `playbooks/deploy-all.yml` - Complete deployment
- `playbooks/cleanup-all.yml` - Complete cleanup

### Component Playbooks
- `playbooks/setup.yml` - Basic server setup
- `playbooks/ingress/setup.yml` - Nginx Ingress Controller
- `playbooks/monitoring/setup.yml` - Prometheus & Grafana
- `playbooks/dashboard/setup.yml` - Kubernetes Dashboard
- `playbooks/argocd/setup.yml` - ArgoCD CI/CD
- `playbooks/vault/setup.yml` - HashiCorp Vault
- `playbooks/jenkins/setup.yml` - Jenkins

### Cleanup Playbooks
Each component has a corresponding cleanup playbook: `playbooks/<component>/cleanup.yml`

---

## 🛡️ Security & Firewall

### Firewall Strategy
**Minimal Exposure**: Only essential ports are exposed:
- **22**: SSH access
- **30080/30443**: Nginx Ingress Controller (HTTP/HTTPS)
- **31000**: Kubernetes Dashboard (HTTPS)

**Most services** are accessed through the Ingress Controller, eliminating the need for individual NodePort firewall rules. The Kubernetes Dashboard is an exception due to subpath routing limitations.

### Benefits
✅ **Smaller Attack Surface**: Only 3 ports exposed instead of many NodePorts  
✅ **Centralized Access**: All services accessible through Ingress Controller  
✅ **Easier Management**: Add new services without firewall changes  
✅ **Better Security**: SSL termination and path-based routing  
✅ **Standard Kubernetes**: Follows Kubernetes best practices  

### Managing UFW Rules
```bash
# Check current rules
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "sudo ufw status"

# Allow a port
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "sudo ufw allow <port>/tcp"

# Remove a rule
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "sudo ufw delete allow <port>/tcp"
```

---

## 📊 Monitoring Stack

### Components
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert management

### Access
- **Grafana**: `http://<HOST>:30080/grafana` (admin/admin)
- **Prometheus**: `http://<HOST>:30080/prometheus`
- **AlertManager**: `http://<HOST>:30302`

---

## 🔄 CI/CD with ArgoCD

### Features
- **GitOps**: Declarative application deployment
- **Automated Sync**: Automatic deployment on git changes
- **Rollback**: Easy rollback to previous versions
- **Multi-cluster**: Support for multiple Kubernetes clusters

### Setup
```bash
# Install ArgoCD
ansible-playbook -i inventory/hosts playbooks/argocd/setup.yml

# Create application
ansible-playbook -i inventory/hosts playbooks/argocd/application.yml
```

### Access
- **UI**: `http://<HOST>:30080/argocd`
- **CLI**: `argocd login <HOST>:30080`

---

## 🔐 HashiCorp Vault

### Features
- **Secrets Management**: Secure storage and access to secrets
- **Dynamic Secrets**: On-demand credential generation
- **Encryption**: Transit and encryption as a service
- **Access Control**: Fine-grained access policies

### Setup
```bash
ansible-playbook -i inventory/hosts playbooks/vault/setup.yml
```

### Access
- **UI**: `http://<HOST>:30201`
- **CLI**: `vault login`

---

## 🏗️ Jenkins

### Features
- **Pipeline as Code**: Jenkinsfile-based pipelines
- **Kubernetes Integration**: Dynamic agent provisioning
- **Plugin Ecosystem**: Extensive plugin support
- **Security**: Role-based access control

### Setup
```bash
ansible-playbook -i inventory/hosts playbooks/jenkins/setup.yml
```

### Access
- **UI**: `http://<HOST>:30000`

---

## 📁 Repository Structure

```
.
├── inventory/                    # Inventory files
│   ├── hosts                    # Server configuration
│   └── hosts.example           # Example configuration
├── playbooks/                   # Ansible playbooks
│   ├── deploy-all.yml          # Master deployment playbook
│   ├── cleanup-all.yml         # Master cleanup playbook
│   ├── setup.yml               # Basic server setup
│   ├── ingress/                # Nginx Ingress Controller
│   ├── monitoring/             # Prometheus & Grafana
│   ├── dashboard/              # Kubernetes Dashboard
│   ├── argocd/                 # ArgoCD CI/CD
│   ├── vault/                  # HashiCorp Vault
│   └── jenkins/                # Jenkins
├── roles/                      # Ansible roles
├── scripts/                    # Utility scripts
├── hello-grpc/                 # Example application
├── requirements.txt            # Python dependencies
├── ansible.cfg                 # Ansible configuration
└── README.md                   # This file
```

---

## 🚨 Troubleshooting

### Common Issues

**Connection Issues:**
```bash
# Test connectivity
ansible -i inventory/hosts servers -m ping

# Check SSH access
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST>
```

**Kubernetes Issues:**
```bash
# Check k3s status
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "sudo systemctl status k3s"

# Check pods
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "kubectl get pods --all-namespaces"
```

**Ingress Issues:**
```bash
# Check ingress controller
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "kubectl get pods -n ingress-nginx"

# Check ingress resources
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "kubectl get ingress --all-namespaces"
```

### Logs
```bash
# View pod logs
kubectl logs -n <namespace> <pod-name>

# View ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

---

## 🔄 Maintenance

### Updates
```bash
# Update all components
ansible-playbook -i inventory/hosts playbooks/deploy-all.yml
```

### Backup
```bash
# Backup important data
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "sudo tar -czf backup-$(date +%Y%m%d).tar.gz /var/lib/rancher/k3s"
```

---

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `ansible-playbook --check`
5. Submit a pull request

---

## 📄 License

MIT License - see LICENSE file for details. 