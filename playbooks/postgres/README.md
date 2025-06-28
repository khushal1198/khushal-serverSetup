# PostgreSQL and pgAdmin Deployment

This playbook sets up PostgreSQL database server and pgAdmin web interface on your Kubernetes cluster.

## 🚀 Quick Start

### Deploy PostgreSQL and pgAdmin
```bash
# Deploy both PostgreSQL and pgAdmin
ansible-playbook -i inventory/hosts playbooks/postgres/setup.yml

# Or as part of complete deployment
ansible-playbook -i inventory/hosts playbooks/deploy-all.yml
```

### Cleanup
```bash
# Remove PostgreSQL and pgAdmin
ansible-playbook -i inventory/hosts playbooks/postgres/cleanup.yml
```

## 🌐 Access Information

### pgAdmin Web Interface
- **Via Ingress**: `http://<HOST>:30080/pgadmin`
- **Direct NodePort**: `http://<HOST>:32544`

### PostgreSQL Database
- **Host**: `<HOST>`
- **Port**: `32543`
- **Database**: `myapp`

### Internal Kubernetes Access
- **Service**: `postgresql.postgres.svc.cluster.local`
- **Port**: `5432`

## 🔐 Default Credentials

### pgAdmin
- **Email**: `admin@admin.com`
- **Password**: `admin123`

### PostgreSQL
- **Username**: `postgres`
- **Password**: `admin123`
- **Database**: `myapp`

## 🔧 Configuration

### Default Settings
- **PostgreSQL Version**: Latest stable from Bitnami
- **Storage**: 8GB persistent volume
- **pgAdmin Storage**: 2GB persistent volume
- **Metrics**: Enabled for Prometheus monitoring

### Customization
Edit the variables in `setup-tasks.yml` to customize:
- Passwords
- Database names
- Storage sizes
- Node ports

## 📊 Connection Examples

### psql Command Line
```bash
psql -h <HOST> -p 32543 -U postgres -d myapp
```

### Connection String
```
postgresql://postgres:admin123@<HOST>:32543/myapp
```

### Python (using psycopg2)
```python
import psycopg2

conn = psycopg2.connect(
    host="<HOST>",
    port="32543",
    database="myapp",
    user="postgres",
    password="admin123"
)
```

### Node.js (using pg)
```javascript
const { Client } = require('pg');

const client = new Client({
  host: '<HOST>',
  port: 32543,
  database: 'myapp',
  user: 'postgres',
  password: 'admin123',
});
```

## 🔒 Security Considerations

### Production Recommendations
1. **Change default passwords** immediately
2. **Use secrets management** (HashiCorp Vault integration available)
3. **Enable SSL/TLS** connections
4. **Configure network policies** to restrict access
5. **Set up regular backups**

### Firewall
- PostgreSQL is accessible via NodePort 32543
- pgAdmin is accessible via NodePort 32544 and Ingress
- Consider restricting access to specific IP ranges

## 📈 Monitoring

- **Metrics**: PostgreSQL metrics are enabled and compatible with Prometheus
- **Health Checks**: Kubernetes readiness and liveness probes configured
- **Logs**: Available via `kubectl logs` in the `postgres` namespace

## 🔧 Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n postgres
```

### View Logs
```bash
# PostgreSQL logs
kubectl logs -n postgres -l app.kubernetes.io/name=postgresql

# pgAdmin logs
kubectl logs -n postgres -l app.kubernetes.io/name=pgadmin4
```

### Test Connection
```bash
# Test from within cluster
kubectl run postgres-client --rm --tty -i --restart='Never' --namespace postgres --image postgres:13 --env="PGPASSWORD=admin123" --command -- psql --host postgresql --username postgres --dbname myapp --port 5432
```

## 🏗️ Components

### PostgreSQL
- **Chart**: Bitnami PostgreSQL
- **Namespace**: `postgres`
- **Service**: `postgresql`
- **Storage**: Persistent volume for data

### pgAdmin
- **Chart**: runix/pgadmin4
- **Namespace**: `postgres`
- **Service**: `pgadmin4`
- **Storage**: Persistent volume for settings

### Additional Services
- **PostgreSQL Client Service**: NodePort access to database
- **Ingress**: pgAdmin web interface routing 