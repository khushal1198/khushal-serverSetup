# Kubernetes Dashboard Playbooks

## Setup
- `setup.yml`: Installs the Kubernetes Dashboard, exposes it on NodePort 31000, creates an admin ServiceAccount, and configures firewall rules.

## Cleanup
- `cleanup.yml`: Removes the Kubernetes Dashboard, related resources, and firewall rules.

---

## Accessing the Dashboard

1. **Run the setup playbook:**
   ```bash
   ansible-playbook -i inventory/hosts playbooks/dashboard/setup.yml
   ```
2. **Open the Dashboard:**
   - URL: `https://<your-server-ip>:31000`
   - Accept the self-signed certificate warning in your browser.
3. **Login:**
   - Use the token provided in the setup output, or generate a new one.

---

## Generating Long-lived Tokens

To generate a long-lived token (valid for 1 year) via SSH:

```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@100.110.142.150 "kubectl -n kubernetes-dashboard create token admin-user --duration=8760h"
```

This will output a token that you can use to log into the Dashboard. Save this token securely!

---

## Features

### What's Included:
- **NodePort 31000**: Dashboard exposed on a fixed port
- **Firewall Configuration**: Automatically allows port 31000 through UFW
- **Authentication Enabled**: Secure token-based login
- **Admin ServiceAccount**: Created for token-based access
- **Self-signed Cert**: Accept the browser warning to proceed

### Access Methods:
1. **Direct Access**: `https://<server-ip>:31000` (NodePort configured to bind to all interfaces)
2. **SSH Tunnel**: `ssh -L 31000:localhost:31000 user@server` then `https://localhost:31000`
3. **Port Forward**: `kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 31000:443`

---

## Cleanup
To remove the dashboard and its admin account:
```bash
ansible-playbook -i inventory/hosts playbooks/dashboard/cleanup.yml
```

---

For more details, see the [Kubernetes Dashboard documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/). 