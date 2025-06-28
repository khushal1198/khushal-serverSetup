# PostgreSQL and pgAdmin Deployment - Schema-Based Production/Testing

This playbook sets up a comprehensive PostgreSQL database server with **production and testing schema separation**, automated backups, and pgAdmin web interface on your Kubernetes cluster.

## 🎯 **Key Features**

- ✅ **Schema-Based Environments**: Separate `prod` and `test` schemas  
- ✅ **Dedicated Users**: Schema-specific users with proper permissions
- ✅ **Automated Backups**: Schema-aware backup system with retention
- ✅ **Auto-Registration**: pgAdmin preconfigured with PostgreSQL server
- ✅ **Sample Data**: Demo users and orders for immediate testing
- ✅ **Testing Utilities**: Data synchronization between environments
- ✅ **Production Ready**: Monitoring, persistence, and security

## 🚀 **Quick Start**

### Deploy Complete Environment
```bash
# Deploy PostgreSQL + pgAdmin + Schemas + Backups
ansible-playbook -i inventory/hosts playbooks/postgres/setup.yml

# Or as part of complete infrastructure
ansible-playbook -i inventory/hosts playbooks/deploy-all.yml
```

### Cleanup
```bash
# Robust cleanup with timeout handling
ansible-playbook -i inventory/hosts playbooks/postgres/cleanup.yml
```

## 🏗️ **Schema-Based Architecture**

### **Production Schema (`prod`)**
- **Purpose**: Live production data
- **User**: `prod_user` (full access to prod schema)
- **Tables**: `prod.users`, `prod.orders`, `prod.user_orders` (view)
- **Environment**: `production`

### **Testing Schema (`test`)**
- **Purpose**: Development and testing data  
- **User**: `test_user` (full access to test + read-only prod)
- **Tables**: `test.users`, `test.orders`, `test.user_orders` (view)
- **Environment**: `testing`

### **Cross-Schema Access**
- `test_user` can **read** production data for testing
- Built-in `copy_prod_to_test()` function for data synchronization
- Isolated environments prevent test data corruption of production

## 🌐 **Access Information**

### **pgAdmin Web Interface**
- **URL**: `http://104.241.54.17:32544`
- **Multi-device**: Works on phones, tablets, computers
- **Auto-configured**: PostgreSQL server pre-registered

### **PostgreSQL Database Connection**
- **Host**: `104.241.54.17`
- **Port**: `32543`
- **Database**: `myapp`

### **Internal Kubernetes Access**
- **Service**: `postgresql.postgres.svc.cluster.local`
- **Port**: `5432`

## 🔐 **User Accounts & Permissions**

### **Database Administrator**
```bash
Username: postgres
Password: admin123
Access: Full database administration
Schemas: Can access all schemas (public, prod, test)
```

### **Production User**
```bash
Username: prod_user  
Password: prod123
Access: Full control of production schema
Default Schema: prod
Search Path: prod, public
```

### **Testing User**
```bash
Username: test_user
Password: test123  
Access: Full control of test schema + read-only prod access
Default Schema: test
Search Path: test, public
```

### **pgAdmin Interface**
```bash
Email: admin@admin.com
Password: admin123
Access: Full database administration via web interface
```

## 📊 **Connection Examples**

### **Production Environment Access**
```bash
# Connect to production schema
psql -h 104.241.54.17 -p 32543 -U prod_user -d myapp

# Query production data
SELECT * FROM prod.users;
SELECT * FROM prod.orders;
SELECT * FROM prod.user_orders;  -- View with joined data
```

### **Testing Environment Access**
```bash
# Connect to test schema
psql -h 104.241.54.17 -p 32543 -U test_user -d myapp

# Query test data
SELECT * FROM test.users;
SELECT * FROM test.orders;

# Read production data (read-only)
SELECT * FROM prod.users;
```

### **Admin Access (All Schemas)**
```bash
# Connect as admin
psql -h 104.241.54.17 -p 32543 -U postgres -d myapp

# Compare environments
SELECT * FROM public.schema_info;

# Access any schema
SELECT * FROM prod.users;
SELECT * FROM test.users;
```

### **Application Connection Strings**

#### **Production Application**
```python
# Python (psycopg2)
conn = psycopg2.connect(
    host="104.241.54.17",
    port=32543,
    database="myapp", 
    user="prod_user",
    password="prod123",
    options="-c search_path=prod,public"
)
```

#### **Testing Application**
```javascript
// Node.js (pg)
const client = new Client({
  host: '104.241.54.17',
  port: 32543,
  database: 'myapp',
  user: 'test_user', 
  password: 'test123',
  search_path: ['test', 'public']
});
```

#### **Generic Admin Connection**
```bash
# Connection URL
postgresql://postgres:admin123@104.241.54.17:32543/myapp
```

## 🎛️ **Testing Utilities**

### **Data Synchronization**
```sql
-- Copy production data to test environment (modifies for testing)
SELECT copy_prod_to_test();

-- Result: 'Production data copied to test environment successfully'
```

### **Environment Comparison**
```sql
-- Quick overview of both environments
SELECT * FROM public.schema_info;

-- Output:
-- schema_name | user_count | order_count | description
-- prod        | 2          | 2           | Production Environment  
-- test        | 3          | 3           | Testing Environment
```

### **Reset Test Data**
```sql
-- Clear test environment
TRUNCATE test.orders, test.users CASCADE;
```

### **Schema Information Job**
```bash
# Get detailed schema information
kubectl apply -f /tmp/postgres-schema-info-job.yaml
kubectl logs -n postgres job/postgres-schema-info

# Output shows tables, data counts, and available backups
```

## 💾 **Backup & Restore System**

### **Automated Backups**
- **Schedule**: Every 6 hours (`0 */6 * * *`)
- **Types**: Full database, Production schema, Test schema
- **Storage**: 5GB dedicated backup PVC
- **Retention**: Last 10 backups of each type
- **Format**: SQL dumps with PostgreSQL 17 compatibility

### **Backup Commands**
```bash
# Trigger manual backup (all schemas)
kubectl create job --from=cronjob/postgres-backup manual-backup-$(date +%s) -n postgres

# Check backup status
kubectl get jobs -n postgres
kubectl logs -n postgres job/manual-backup-<timestamp>
```

### **Restore Commands**
```bash
# Restore full database
kubectl apply -f /tmp/postgres-restore-job.yaml

# Restore production schema only
kubectl apply -f /tmp/postgres-restore-prod-job.yaml

# Restore test schema only  
kubectl apply -f /tmp/postgres-restore-test-job.yaml

# Check restore status
kubectl logs -n postgres job/postgres-restore-manual
kubectl logs -n postgres job/postgres-restore-prod
kubectl logs -n postgres job/postgres-restore-test
```

### **Backup Files**
```bash
# List available backups
kubectl exec -n postgres postgresql-0 -- ls -la /backup/

# Backup naming convention:
# full_backup_YYYYMMDD_HHMMSS.sql      # Complete database
# prod_backup_YYYYMMDD_HHMMSS.sql      # Production schema only
# test_backup_YYYYMMDD_HHMMSS.sql      # Test schema only
# latest_backup.sql                    # Symlink to latest full backup
# latest_prod_backup.sql               # Symlink to latest prod backup  
# latest_test_backup.sql               # Symlink to latest test backup
```

## 📈 **Monitoring & Observability**

### **Built-in Monitoring**
- ✅ **PostgreSQL Metrics**: Enabled for Prometheus
- ✅ **Health Checks**: Kubernetes readiness/liveness probes
- ✅ **Backup Monitoring**: Job success/failure tracking
- ✅ **Schema Metrics**: User/table counts via `schema_info` view

### **Check System Status**
```bash
# All PostgreSQL components
kubectl get all -n postgres

# Backup system status
kubectl get cronjobs -n postgres
kubectl get pvc -n postgres

# Resource usage
kubectl top pods -n postgres
```

### **Monitoring Queries**
```sql
-- Schema statistics
SELECT * FROM public.schema_info;

-- Recent activity
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del 
FROM pg_stat_user_tables;

-- Database size
SELECT pg_size_pretty(pg_database_size('myapp'));
```

## 🔧 **pgAdmin Web Interface**

### **Access & Navigation**
1. **Login**: Navigate to `http://104.241.54.17:32544`
2. **Credentials**: `admin@admin.com` / `admin123`
3. **Server**: PostgreSQL Server (auto-registered)
4. **Expand**: `PostgreSQL Server → myapp → Schemas`
5. **Schemas Available**: `public`, `prod`, `test`

### **Schema-Specific Queries**
1. **Right-click** on schema (`prod` or `test`)
2. **Select** "Query Tool"
3. **Write** schema-specific queries:
   ```sql
   -- In prod schema query tool
   SELECT * FROM users;    -- Automatically uses prod.users
   
   -- In test schema query tool  
   SELECT * FROM users;    -- Automatically uses test.users
   ```

### **Cross-Schema Queries**
```sql
-- Compare data between environments
SELECT 'prod' as env, COUNT(*) as users FROM prod.users
UNION ALL  
SELECT 'test' as env, COUNT(*) as users FROM test.users;
```

## 🔒 **Security Considerations**

### **Production Hardening**
```bash
# 1. Change default passwords immediately
ALTER USER postgres PASSWORD 'new_strong_password';
ALTER USER prod_user PASSWORD 'new_prod_password';
ALTER USER test_user PASSWORD 'new_test_password';

# 2. Update pgAdmin password via web interface

# 3. Review user permissions
\du   -- List users and roles
```

### **Network Security**
- **NodePort Access**: PostgreSQL (32543), pgAdmin (32544)
- **Internal Access**: Service-to-service communication only
- **Firewall**: Consider IP restrictions for production
- **SSL/TLS**: Enable for production environments

### **Access Control**
- **Schema Isolation**: Users cannot cross-contaminate data
- **Read-Only Access**: Test users can safely read production
- **Admin Separation**: Different credentials for different roles

## 🛠️ **Configuration & Customization**

### **File Structure**
```
playbooks/postgres/
├── setup.yml                  # Main deployment
├── setup-tasks.yml           # Deployment logic
├── cleanup.yml               # Standalone cleanup  
├── cleanup-tasks.yml         # Cleanup logic
├── schema-init.sql           # Schema initialization
├── backup-pvc.yaml           # Backup storage
├── backup-scripts.yaml      # Backup/restore scripts
├── backup-cronjob.yaml       # Automated backup schedule
├── restore-job.yaml          # Full database restore
├── restore-prod-job.yaml     # Production schema restore
├── restore-test-job.yaml     # Test schema restore
├── schema-info-job.yaml      # Schema information utility
└── README.md                 # This documentation
```

### **Customization Variables**
Edit `setup-tasks.yml` to customize:
```yaml
postgres_password: "admin123"        # Admin password
postgres_database: "myapp"           # Database name
postgres_nodeport: 32543            # Database port
postgres_storage_size: "8Gi"        # Database storage
pgadmin_nodeport: 32544             # pgAdmin port
pgadmin_storage_size: "2Gi"         # pgAdmin storage
backup_storage_size: "5Gi"          # Backup storage
backup_schedule: "0 */6 * * *"      # Backup frequency
```

### **Schema Customization**
Modify `schema-init.sql` to:
- Add your own tables
- Change sample data
- Modify user permissions
- Add additional schemas
- Create custom functions

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Schema Not Found**
```bash
# Check if schemas exist
kubectl exec -n postgres postgresql-0 -- psql -U postgres -d myapp -c "\dn+"

# Re-run schema initialization if needed
kubectl exec -n postgres postgresql-0 -- psql -U postgres -d myapp -f /tmp/schema-init.sql
```

#### **Connection Issues**
```bash
# Test connectivity
kubectl get pods -n postgres
kubectl logs -n postgres postgresql-0

# Test from within cluster
kubectl exec -n postgres postgresql-0 -- psql -U postgres -d myapp -c "SELECT 1;"
```

#### **Backup Issues**
```bash
# Check backup system
kubectl get cronjobs -n postgres
kubectl describe cronjob postgres-backup -n postgres

# Manual backup test
kubectl create job --from=cronjob/postgres-backup test-backup -n postgres
kubectl logs -n postgres job/test-backup
```

#### **PVC Stuck in Terminating**
```bash
# Use robust cleanup (already handles this)
ansible-playbook -i inventory/hosts playbooks/postgres/cleanup.yml

# Manual fix if needed
kubectl patch pvc postgres-backup-pvc -n postgres -p '{"metadata":{"finalizers":null}}'
```

### **Debug Commands**
```bash
# All resources
kubectl get all,pvc,secrets,configmaps -n postgres

# Detailed pod info
kubectl describe pod postgresql-0 -n postgres

# Recent events
kubectl get events -n postgres --sort-by='.lastTimestamp'

# Resource usage
kubectl top pods -n postgres
kubectl exec -n postgres postgresql-0 -- df -h
```

## 🎯 **Best Practices**

### **Development Workflow**
1. **Develop in test schema** (`test_user`)
2. **Test with production data** using `copy_prod_to_test()`
3. **Deploy to production schema** (`prod_user`)
4. **Monitor both environments** via pgAdmin
5. **Regular backups** automatic every 6 hours

### **Data Management**
- **Use schemas consistently** - always specify `prod.table` or `test.table`
- **Test migrations** in test schema first
- **Backup before major changes**
- **Monitor storage usage** regularly

### **Security Operations**
- **Change default passwords** for production
- **Use least-privilege principle** - connect with appropriate user
- **Regular access reviews** of user permissions
- **Monitor connection logs** for suspicious activity

---

## 📚 **Quick Reference**

### **Essential Commands**
```bash
# Deploy
ansible-playbook -i inventory/hosts playbooks/postgres/setup.yml

# Access Production
psql -h 104.241.54.17 -p 32543 -U prod_user -d myapp

# Access Testing  
psql -h 104.241.54.17 -p 32543 -U test_user -d myapp

# Backup
kubectl create job --from=cronjob/postgres-backup backup-$(date +%s) -n postgres

# Schema Info
kubectl apply -f /tmp/postgres-schema-info-job.yaml && kubectl logs -n postgres job/postgres-schema-info

# Cleanup
ansible-playbook -i inventory/hosts playbooks/postgres/cleanup.yml
```

### **Key URLs**
- **pgAdmin**: `http://104.241.54.17:32544`
- **Database**: `104.241.54.17:32543`

### **Default Credentials**
- **Admin**: `postgres/admin123`
- **Production**: `prod_user/prod123`  
- **Testing**: `test_user/test123`
- **pgAdmin**: `admin@admin.com/admin123`

---

**Happy Database Management!** 🎉 