# Server Setup Repository

This repository contains Ansible playbooks and configurations for setting up and maintaining server infrastructure.

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT 