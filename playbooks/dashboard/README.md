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
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "kubectl -n kubernetes-dashboard create token admin-user --duration=8760h"
```