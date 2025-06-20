# ArgoCD Playbooks

## Setup
- `setup.yml`: Installs ArgoCD on your Kubernetes cluster and exposes the UI via NodePort.
- `application.yml`: Creates an ArgoCD Application to automatically deploy your app from GitHub.

## Cleanup
- `cleanup.yml`: Removes ArgoCD and all its resources from your cluster.
- `application-cleanup.yml`: Removes the ArgoCD Application.

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

## Setting Up Your Application for CI/CD

### Prerequisites
1. Your GitHub repository should contain Kubernetes manifests (YAML files)
2. The manifests should be in a specific path (e.g., `k8s/`, `manifests/`, etc.)

### Configuration
The playbook is currently configured for the **hello_grpc** application:
```yaml
app_name: "hello-grpc"                    # Application name
repo_url: "https://github.com/khushal1198/hello_grpc"  # GitHub repo
repo_path: "k8s"                          # Path to K8s manifests
target_namespace: "default"               # Namespace to deploy to
target_revision: "master"                 # Branch to track
```

### What Gets Deployed
The hello_grpc application includes:
- **Deployment**: 3 replicas of the gRPC server
- **Service**: LoadBalancer type exposing port 50051
- **Image**: `ghcr.io/khushal1198/hello_grpc:latest` (built by GitHub Actions)
- **Health Checks**: gRPC readiness and liveness probes

### Deploy Your Application
```bash
ansible-playbook -i inventory/hosts playbooks/argocd/application.yml
```

### How It Works
- ArgoCD will watch your GitHub repository
- When you push changes to the specified branch, ArgoCD automatically deploys
- The application will be visible in the ArgoCD UI
- You can monitor deployment status and logs

### Accessing the Deployed Service
Once deployed, the hello_grpc service will be available:
- **Internal**: `hello-grpc.default.svc.cluster.local:50051`
- **External**: Via LoadBalancer IP (check with `kubectl get svc hello-grpc`)

---

## Port Information
- **Default ArgoCD Service:** ClusterIP (internal access only)
- **NodePort:** Dynamically assigned (30000-32767 range)
- **Alternative:** Use port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`

---

For more details, see the [official ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/getting_started/). 