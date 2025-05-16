# Vault Ansible Role

This Ansible role installs and configures HashiCorp Vault on Kubernetes.

## Installation

- The role installs Vault using Helm in standalone mode with file storage.
- Ensure you have Ansible and Helm installed on your control node.

## Initialization and Unsealing

- Vault is initialized and unsealed automatically by the role.
- The unseal key and root token are generated and displayed after setup.

## Secure Credential Management

- **Important:** Store the root token and unseal key securely. Do not commit them to version control.
- Use a password manager or a secure vault to store these credentials.

## Usage

- Include this role in your Ansible playbook to set up Vault on Kubernetes.
- Example:
  ```yaml
  - hosts: servers
    roles:
      - vault_k8s
  ```

## Contributing

Feel free to submit issues and pull requests. 