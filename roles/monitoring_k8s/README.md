# Monitoring Ansible Role

This Ansible role installs and configures Prometheus, Grafana, and AlertManager on Kubernetes.

## Installation

- The role installs the kube-prometheus-stack using Helm.
- Ensure you have Ansible and Kubernetes access configured on your control node.

## Access

- Prometheus: http://<server-ip>:30300
- Grafana: http://<server-ip>:30301 (Username: admin, Password: admin)
- AlertManager: http://<server-ip>:30302

## Usage

- Include this role in your Ansible playbook to set up monitoring on Kubernetes.
- Example:
  ```yaml
  - hosts: servers
    roles:
      - monitoring_k8s
  ```

## Contributing

Feel free to submit issues and pull requests. 