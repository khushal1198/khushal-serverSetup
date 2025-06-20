# Monitoring Stack Playbooks

## Setup
- `setup.yml`: Installs Prometheus, Grafana, and AlertManager on your Kubernetes cluster using the monitoring_k8s role.

## Cleanup
- `cleanup.yml`: Removes the monitoring stack and all its resources from your cluster.

---

## Accessing Monitoring Services After Installation

### 1. Prometheus
```bash
kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `http://<your-server-ip>:<NodePort>`

### 2. Grafana
```bash
kubectl -n monitoring get svc prometheus-grafana -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `http://<your-server-ip>:<NodePort>`
- **Default credentials:**
  - Username: `admin`
  - Password: `admin`

### 3. AlertManager
```bash
kubectl -n monitoring get svc prometheus-kube-prometheus-alertmanager -o jsonpath='{.spec.ports[0].nodePort}'
```
- Open: `http://<your-server-ip>:<NodePort>`

---

## Default Ports (as configured in main README)
- **Prometheus:** `http://<server-ip>:30300`
- **Grafana:** `http://<server-ip>:30301` (admin/admin)
- **AlertManager:** `http://<server-ip>:30302`

---

## Getting Grafana Admin Password
If the default password doesn't work:
```bash
kubectl -n monitoring get secret prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

---

For more details, see the [Prometheus Operator documentation](https://github.com/prometheus-operator/kube-prometheus). 