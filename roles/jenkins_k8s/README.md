# Jenkins Ansible Role

This Ansible role installs and configures Jenkins on Kubernetes.

## Installation

- The role installs Jenkins using the provided Ansible role.
- Ensure you have Ansible and Kubernetes access configured on your control node.

## Access

- Jenkins UI is accessible at `http://<server-ip>:30000`.
- Default credentials are set during installation.

## Usage

- Include this role in your Ansible playbook to set up Jenkins on Kubernetes.
- Example:
  ```yaml
  - hosts: servers
    roles:
      - jenkins_k8s
  ```

## Contributing

Feel free to submit issues and pull requests. 