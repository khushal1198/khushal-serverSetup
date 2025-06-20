# Jenkins Playbooks

## Setup
- `setup.yml`: Installs Jenkins on your Kubernetes cluster using the jenkins_k8s role.

## Cleanup
- `cleanup.yml`: Removes Jenkins and all its resources from your cluster.

---

## Accessing Jenkins After Installation

### 1. Get the Jenkins NodePort
```bash
kubectl -n jenkins get svc jenkins -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `http://<your-server-ip>:<NodePort>`

### 2. Get the Initial Admin Password
```bash
kubectl -n jenkins exec -it $(kubectl -n jenkins get pods -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### 3. Login
- **Username:** `admin` (or as configured during setup)
- **Password:** (from above)

### 4. Complete the Jenkins setup
- Follow the Jenkins setup wizard to configure plugins and create your admin user.

---

For more details, see the [official Jenkins documentation](https://www.jenkins.io/doc/). 