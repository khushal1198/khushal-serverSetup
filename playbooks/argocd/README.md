# ArgoCD Playbooks

## Setup
- `setup.yml`: Installs ArgoCD on your Kubernetes cluster and exposes the UI via NodePort.

## Cleanup
- `cleanup.yml`: Removes ArgoCD and all its resources from your cluster.

---

## Accessing ArgoCD After Fresh Install

### 1. Get the ArgoCD NodePort
```bash
kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `https://<your-server-ip>:<NodePort>`

### 2. Get the Initial Admin Password
```bash
kubectl -n argocd exec -it $(kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}') -- argocd admin initial-password
```
- This will print the initial admin password.

### 3. Login
- **Username:** `admin`
- **Password:** (from above)

### 4. Change the password after first login
- You will be prompted to change the password on first login, or you can do it later via the UI or CLI.

---

## Port Information
- **Default ArgoCD Service:** ClusterIP (internal access only)
- **NodePort:** Dynamically assigned (30000-32767 range)
- **Alternative:** Use port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`

---

For more details, see the [official ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/getting_started/). 