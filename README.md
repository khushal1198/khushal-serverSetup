# Server Setup with Ansible

This repository contains Ansible playbooks and roles for setting up and managing server configurations, including Jenkins and HashiCorp Vault on Kubernetes.

## Firewall Configuration (UFW)

The server has UFW (Uncomplicated Firewall) enabled by default for security. When setting up new services, you may need to allow specific ports.

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

### Current Ports Allowed
- **22**: SSH access
- **80/443**: HTTP/HTTPS
- **31000**: Kubernetes Dashboard
- **32000-32002**: Monitoring stack (Grafana, Prometheus, Node Exporter)

---

## Jenkins Setup

### Installation
- Jenkins is installed on Kubernetes using the provided Ansible role.
- The role ensures idempotency and handles cleanup if needed.

### Access
- Jenkins UI is accessible at `http://<server-ip>:30000`.
- Default credentials are set during installation.

## HashiCorp Vault Setup

### Installation
- Vault is installed on Kubernetes using the provided Ansible role.
- The role configures Vault in standalone mode with file storage.

### Initialization and Unsealing
- Vault is initialized and unsealed automatically by the Ansible role.
- The unseal key and root token are generated and displayed after setup.

### Access
- Vault UI is accessible at `http://<server-ip>:30201`.
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

## License

MIT 