# HashiCorp Vault Playbooks

## Setup
- `setup.yml`: Installs HashiCorp Vault on your Kubernetes cluster using the vault_k8s role.

## Cleanup
- `cleanup.yml`: Removes Vault and all its resources from your cluster.

---

## Accessing Vault After Installation

### 1. Get the Vault NodePort
```bash
kubectl -n vault-system get svc vault-ui -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `http://<your-server-ip>:<NodePort>`

### 2. Initialize Vault (if not already done)
```bash
kubectl -n vault-system exec -it vault-0 -- vault operator init
```
- This will generate 5 unseal keys and a root token.
- **IMPORTANT:** Save these securely!

### 3. Unseal Vault
```bash
kubectl -n vault-system exec -it vault-0 -- vault operator unseal <unseal-key-1>
kubectl -n vault-system exec -it vault-0 -- vault operator unseal <unseal-key-2>
kubectl -n vault-system exec -it vault-0 -- vault operator unseal <unseal-key-3>
```

### 4. Login to Vault
- Use the root token from step 2 to login via the UI or CLI.

---

## Security Notes
- Store the unseal keys and root token securely
- Consider using auto-unseal for production environments
- Rotate keys regularly

---

For more details, see the [official Vault documentation](https://www.vaultproject.io/docs). 