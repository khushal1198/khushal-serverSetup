# Monitoring Stack Playbooks

## Setup
- `setup.yml`: Installs Prometheus, Grafana, and Node Exporter on your Kubernetes cluster using Helm.

## Cleanup
- `cleanup.yml`: Removes the monitoring stack and all its resources from your cluster.

---

## Accessing Monitoring Services

### 1. Grafana Dashboard
- **URL**: `http://<your-server-ip>:32000`
- **Username**: `admin`
- **Password**: `admin123` (change this in setup.yml)

### 2. Prometheus
- **URL**: `http://<your-server-ip>:32001`

### 3. Node Exporter (Server Metrics)
- **URL**: `http://<your-server-ip>:32002/metrics`

---

## Setup Instructions

1. **Run the setup playbook:**
   ```bash
   ansible-playbook -i inventory/hosts playbooks/monitoring/setup.yml
   ```

2. **Access Grafana and import dashboards:**
   - Go to `http://<server-ip>:32000`
   - Login with admin/admin123
   - Import these dashboard IDs:
     - **Node Exporter**: `1860` (server metrics)
     - **Kubernetes Cluster**: `315` (cluster overview)
     - **Kubernetes Pods**: `6417` (pod metrics)

---

## What's Included

### Monitoring Components:
- **Prometheus**: Time-series database for metrics
- **Grafana**: Visualization and dashboard platform
- **Node Exporter**: Server hardware and OS metrics
- **kube-state-metrics**: Kubernetes cluster metrics
- **AlertManager**: Alerting (configured but not exposed)

### Metrics Collected:
- **Server Resources**: CPU, memory, disk, network
- **Kubernetes**: Pods, services, nodes, deployments
- **Applications**: Your hello_grpc service metrics

### Ports:
- **Grafana**: 32000
- **Prometheus**: 32001  
- **Node Exporter**: 32002

---

## Getting Grafana Admin Password
If you need to retrieve the admin password:
```bash
ssh -i ~/.ssh/id_rsa_jenkins khushal@<HOST> "kubectl -n monitoring get secret prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
```