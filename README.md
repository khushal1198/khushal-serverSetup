# Server Setup with Ansible

This repository contains Ansible playbooks and roles for setting up and managing server configurations, including Jenkins and HashiCorp Vault on Kubernetes.

## Firewall Configuration (UFW)

The server has UFW (Uncomplicated Firewall) enabled by default for security. With Nginx Ingress Controller, firewall management is simplified.

### Current Firewall Strategy

**Minimal Firewall Rules**: Only essential ports are exposed:
- **22**: SSH access
- **30080/30443**: Nginx Ingress Controller (HTTP/HTTPS)

**All other services** are accessed through the Ingress Controller, eliminating the need for individual NodePort firewall rules.

### Managing UFW Rules

**Check current rules:**
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "sudo ufw status"
```

**Allow a port:**
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "sudo ufw allow <port>/tcp"
```

**Remove a rule:**
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "sudo ufw delete allow <port>/tcp"
```

**Disable UFW (not recommended):**
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "sudo ufw disable"
```

### Benefits of Ingress + UFW Approach

✅ **Smaller Attack Surface**: Only 3 ports exposed instead of many NodePorts  
✅ **Centralized Access**: All services accessible through Ingress Controller  
✅ **Easier Management**: Add new services without firewall changes  
✅ **Better Security**: SSL termination and path-based routing  
✅ **Standard Kubernetes**: Follows Kubernetes best practices  

---

## Nginx Ingress Controller

**Solution to NodePort Issues**: k3s NodePorts don't bind to external interfaces by default. Nginx Ingress Controller solves this by providing proper external access to all services.

### Setup
```bash
ansible-playbook -i inventory/hosts playbooks/ingress/setup.yml
```

### Access All Services
- **HTTP**: `http://100.110.142.150:30080`
- **HTTPS**: `https://100.110.142.150:30443`

### Service URLs (after creating Ingress resources):
- ArgoCD: `/argocd`
- Grafana: `/grafana`
- Prometheus: `/prometheus`
- Kubernetes Dashboard: `/dashboard`

---

## Jenkins Setup

### Installation
- Jenkins is installed on Kubernetes using the provided Ansible role.
- The role ensures idempotency and handles cleanup if needed.

### Access
- Jenkins UI is accessible at `http://<your-server-ip>:30000`.
- Default credentials are set during installation.

## HashiCorp Vault Setup

### Installation
- Vault is installed on Kubernetes using the provided Ansible role.
- The role configures Vault in standalone mode with file storage.

### Initialization and Unsealing
- Vault is initialized and unsealed automatically by the Ansible role.
- The unseal key and root token are generated and displayed after setup.

### Access
- Vault UI is accessible at `http://<your-server-ip>:30201`.
- **Important:** Store the root token and unseal key securely. Do not commit them to version control.

## Monitoring Stack

### Access
- Prometheus: http://<server-ip>:30300
- Grafana: http://<server-ip>:30301 (Username: admin, Password: admin)
- AlertManager: http://<server-ip>:30302

## Usage
- Run the Ansible playbooks to set up or clean up Jenkins and Vault.
- Ensure you have Ansible installed and configured correctly.

## Contributing
Feel free to submit issues and pull requests.

## Structure

```
.
├── inventory/           # Inventory files for different environments
├── playbooks/          # Ansible playbooks
│   ├── ingress/        # Nginx Ingress Controller
│   ├── monitoring/     # Prometheus & Grafana
│   ├── dashboard/      # Kubernetes Dashboard
│   ├── argocd/         # ArgoCD CI/CD
│   ├── vault/          # HashiCorp Vault
│   └── jenkins/        # Jenkins
├── roles/             # Ansible roles
├── group_vars/        # Group variables
├── host_vars/         # Host-specific variables
└── requirements.txt   # Python dependencies
```

## Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- SSH access to target servers

## Getting Started

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure your inventory:
   - Copy `inventory/hosts.example` to `inventory/hosts`
   - Update the inventory file with your server details

3. Run playbooks:
   ```bash
   ansible-playbook -i inventory/hosts playbooks/setup.yml
   ```

## Available Playbooks

- `playbooks/setup.yml`: Basic server setup
- `playbooks/security.yml`: Security hardening
- `playbooks/monitoring.yml`: Monitoring setup
- `playbooks/ingress/setup.yml`: Nginx Ingress Controller

## License

MIT 