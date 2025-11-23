# Cluster Component - PASO 2

Este componente despliega toda la infraestructura del cluster ECS para FilmLens en AWS.

## 🎯 Componentes Creados

1. **Security Groups** - ALB, API Service, Query API Service
2. **IAM Roles** - Execution Role + Task Roles (API, Query API)
3. **Application Load Balancer** - Con HTTPS y routing por host
4. **ECS Cluster + Services** - API (puerto 8000) y Query API (puerto 8001)
5. **Route 53 DNS Records** - filmlens.api.atesorapp.com, filmlens.query.atesorapp.com

## 📋 Pre-requisitos

### 1. PASO 1 completado

Asegúrate de que el componente `internet-config/` (PASO 1) esté desplegado:

```bash
cd ../internet-config/
terraform output
```

Debes ver:
- ✅ `certificate_arn` - Certificado SSL ISSUED
- ✅ `hosted_zone_id` - Hosted Zone creada
- ✅ `domain_name` - atesorapp.com

### 2. Obtener IDs de Subnets

```bash
# VPC ID (ya lo tienes)
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text

# Private Subnets (para ECS Tasks)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-0ead70b6c33f41b92" \
  --query "Subnets[?MapPublicIpOnLaunch==\`false\`].[SubnetId,AvailabilityZone]" \
  --output table

# Public Subnets (para ALB)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-0ead70b6c33f41b92" \
  --query "Subnets[?MapPublicIpOnLaunch==\`true\`].[SubnetId,AvailabilityZone]" \
  --output table
```

### 3. Crear Secret en Secrets Manager

Crea un secret con la DATABASE_URL de PostgreSQL:

```bash
# Formato: postgresql://username:password@host:port/database
aws secretsmanager create-secret \
  --name filmlens/db/url \
  --description "Database connection URL for FilmLens" \
  --secret-string "postgresql://filmlens_user:YOUR_PASSWORD@your-rds-endpoint.us-east-1.rds.amazonaws.com:5432/filmlens" \
  --region us-east-1

# Obtener el ARN del secret
aws secretsmanager describe-secret \
  --secret-id filmlens/db/url \
  --query 'ARN' \
  --output text
```

### 4. Verificar Imágenes Docker en ECR

```bash
# Listar repositorios ECR
aws ecr describe-repositories --region us-east-1

# Verificar imágenes en miad-api
aws ecr describe-images \
  --repository-name miad-api \
  --region us-east-1 \
  --query 'imageDetails[*].[imageTags[0],imagePushedAt]' \
  --output table

# Verificar imágenes en miad-query-api
aws ecr describe-images \
  --repository-name miad-query-api \
  --region us-east-1 \
  --query 'imageDetails[*].[imageTags[0],imagePushedAt]' \
  --output table
```

## 🚀 Configuración

### 1. Editar terraform.tfvars

Actualiza los valores en `terraform.tfvars`:

```hcl
# Private Subnets (reemplaza con tus subnet IDs)
private_subnet_ids = [
  "subnet-abc123",
  "subnet-def456"
]

# Public Subnets (reemplaza con tus subnet IDs)
public_subnet_ids = [
  "subnet-ghi789",
  "subnet-jkl012"
]

# Database Secret ARN (del paso 3)
db_secret_arn = "arn:aws:secretsmanager:us-east-1:020194054005:secret:filmlens/db/url-AbCdEf"
```

### 2. Actualizar Security Group de RDS

**IMPORTANTE:** Después de desplegar, debes actualizar el Security Group de tu RDS para permitir tráfico desde los Security Groups de ECS:

```bash
# Obtener Security Group IDs de ECS (después de terraform apply)
terraform output security_group_api_id
terraform output security_group_query_api_id

# Obtener Security Group ID de RDS
aws rds describe-db-instances \
  --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' \
  --output text

# Agregar reglas de ingress al Security Group de RDS
aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SG_ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <SG_API_ID>

aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SG_ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <SG_QUERY_API_ID>
```

## 📦 Despliegue

### 1. Inicializar Terraform

```bash
cd infrastructure/components/cluster/
terraform init
```

### 2. Planear cambios

```bash
terraform plan
```

**Recursos a crear (~25 recursos):**
- 3 Security Groups (ALB, API, Query API)
- 3 IAM Roles (Execution, Task API, Task Query API)
- 1 ALB + 2 Listeners + 2 Target Groups + 2 Listener Rules
- 1 ECS Cluster + 2 Task Definitions + 2 Services
- 2 CloudWatch Log Groups
- 2 Route 53 DNS Records

### 3. Aplicar configuración

```bash
terraform apply
```

⏱️ **Tiempo estimado:** 10-15 minutos

### 4. Verificar despliegue

```bash
# Ver outputs
terraform output

# Verificar servicios ECS
aws ecs list-services --cluster MIAD-cluster

# Verificar tasks corriendo
aws ecs list-tasks --cluster MIAD-cluster --desired-status RUNNING

# Ver logs de API
aws logs tail /ecs/MIAD/api --follow

# Ver logs de Query API
aws logs tail /ecs/MIAD/query-api --follow
```

## 📊 Verificación

### 1. Health Checks del ALB

```bash
# Verificar target groups
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_arn | sed 's/loadbalancer/targetgroup/')
```

### 2. Probar endpoints

```bash
# API Service
curl -v https://filmlens.api.atesorapp.com/health

# Query API Service
curl -v https://filmlens.query.atesorapp.com/health
```

### 3. Verificar DNS

```bash
# Resolver DNS de API
dig filmlens.api.atesorapp.com

# Resolver DNS de Query API
dig filmlens.query.atesorapp.com
```

## 🔧 Troubleshooting

### Tasks no arrancan

```bash
# Ver eventos del servicio
aws ecs describe-services \
  --cluster MIAD-cluster \
  --services MIAD-api-service \
  --query 'services[0].events[0:5]'

# Ver logs del task
aws logs tail /ecs/MIAD/api --since 30m
```

### Target Health "unhealthy"

```bash
# Verificar health check del target group
aws elbv2 describe-target-health \
  --target-group-arn <TG_ARN>

# Verificar que el path /health existe en la aplicación
curl http://<TASK_PRIVATE_IP>:8000/health
```

### Error: Secret not found

```bash
# Verificar que el secret existe
aws secretsmanager get-secret-value --secret-id filmlens/db/url

# Verificar permisos del Execution Role
aws iam get-role-policy \
  --role-name MIAD-ecs-execution-role \
  --policy-name secrets-manager-access
```

## 🧹 Destruir (solo para testing)

```bash
terraform destroy
```

⚠️ **IMPORTANTE:** Esto destruirá:
- Todos los servicios ECS
- ALB y sus listeners
- Security Groups
- IAM Roles
- Route 53 Records (pero NO la Hosted Zone)

## 💰 Costo Estimado POC (1 semana)

- ECS Fargate (2 services, 1 task each): ~$4.50
- ALB: ~$5.50
- CloudWatch Logs: ~$0.50
- **Total semanal: ~$10.50** (sin incluir RDS)

## 📚 Arquitectura Desplegada

```
Internet
    ↓
┌─────────────────────────┐
│  Route 53 DNS           │
│  - filmlens.api         │
│  - filmlens.query       │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│  ALB (Public Subnets)   │
│  - Port 443 (HTTPS)     │
│  - SSL Certificate      │
└───────────┬─────────────┘
            ↓
    ┌───────┴────────┐
    ↓                ↓
┌─────────┐    ┌─────────────┐
│ API     │    │ Query API   │
│ :8000   │    │ :8001       │
│ (ECS)   │    │ (ECS)       │
└────┬────┘    └─────┬───────┘
     └────────┬──────┘
              ↓
      ┌─────────────┐
      │ RDS Postgres│
      │ :5432       │
      └─────────────┘
```

## 🔄 Próximos Pasos

1. ✅ Ejecutar migraciones de base de datos
2. ✅ Configurar monitoreo con CloudWatch Alarms
3. ✅ Implementar CI/CD con GitHub Actions
4. ✅ Habilitar auto-scaling (para producción)
5. ✅ Configurar backup de RDS
