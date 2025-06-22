# HashiCorp Vault Playbooks

## Setup
- `setup.yml`: Installs HashiCorp Vault on your Kubernetes cluster using Helm.

## Cleanup
- `cleanup.yml`: Removes Vault and all its resources from your cluster.

---

## Accessing Vault After Installation

### Access Information
- **UI**: `http://<HOST>:30201`
- **NodePort**: 30201
- **Namespace**: vault

### Important Note
Vault is served via NodePort (port 30201) following HashiCorp's official recommendation to avoid subpath routing issues with ingress controllers. HashiCorp does not recommend hosting Vault behind a subpath like `/vault` as it breaks the UI and API due to absolute path generation in Vault's frontend.

### 1. Access Vault UI
- Open: `http://<HOST>:30201`
- You'll be redirected to: `http://<HOST>:30201/ui/`

### 2. Login to Vault
- **Username**: (leave blank)
- **Password**: `root` (dev mode root token)

### 3. Verify Vault Status
```bash
# Check if Vault pod is running
kubectl get pods -n vault

# Check Vault service
kubectl get svc -n vault

# Get Vault logs
kubectl logs -n vault vault-0
```

---

## Configuration Details

### Dev Mode Setup
- Vault is configured in dev mode for testing
- Root token is pre-set to "root"
- No unsealing required
- Data is not persisted (will be lost on pod restart)

### Production Considerations
- Use production mode with proper storage backend
- Configure auto-unseal for high availability
- Set up proper authentication methods
- Enable audit logging
- Use TLS/HTTPS in production

---

## Security Notes
- Dev mode is for testing only - not for production use
- Store the root token securely
- Consider using auto-unseal for production environments
- Rotate keys regularly
- Enable audit logging in production

---

For more details, see the [official Vault documentation](https://www.vaultproject.io/docs). 