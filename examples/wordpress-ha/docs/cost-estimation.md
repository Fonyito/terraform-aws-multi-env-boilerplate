# Estimación de Costes - WordPress High Availability

Este documento proporciona una estimación detallada de los costes mensuales para cada entorno de la arquitectura de WordPress HA en AWS.

**Región**: us-east-1 (N. Virginia)  
**Moneda**: USD  
**Fecha de estimación**: Abril 2026

---

## 📊 Resumen Ejecutivo

| Entorno | Coste Mensual Estimado | Coste Anual Estimado |
|---------|------------------------|----------------------|
| **Development** | $50 - $70 | $600 - $840 |
| **Staging** | $120 - $150 | $1,440 - $1,800 |
| **Production** | $250 - $350 | $3,000 - $4,200 |

**Nota**: Los costes reales pueden variar según el uso de datos, transferencias, snapshots y servicios adicionales.

---

## 💻 Entorno de Desarrollo (dev)

### Configuración

- **Instancias EC2**: 1 t3.micro
- **RDS**: db.t3.micro, single-AZ
- **Auto Scaling**: 1-3 instancias
- **NAT Gateway**: 2 (Multi-AZ)
- **EFS**: Almacenamiento estándar
- **Backups**: Retención de 3 días

### Desglose de Costes

| Servicio | Especificación | Coste Mensual |
|----------|----------------|---------------|
| **EC2 Instances** | 1x t3.micro (730 horas/mes) | $7.59 |
| **EBS Volumes** | 8 GB gp3 por instancia | $0.80 |
| **Application Load Balancer** | 1 ALB + LCU | $16.20 + $5.00 |
| **NAT Gateway** | 2x NAT Gateway (Multi-AZ) | $65.70 |
| **NAT Gateway Data** | 10 GB procesados | $0.90 |
| **RDS MySQL** | db.t3.micro, single-AZ, 20 GB | $15.33 |
| **RDS Storage** | 20 GB gp3 | $2.30 |
| **RDS Backup** | 20 GB (3 días retención) | $2.00 |
| **EFS** | 5 GB almacenamiento estándar | $1.50 |
| **Data Transfer** | 10 GB salida a Internet | $0.90 |

**Total Estimado**: **$50 - $70/mes**

### Optimizaciones Posibles

- ✅ Usar un solo NAT Gateway en dev (ahorro de ~$33/mes)
- ✅ Apagar instancias fuera de horario laboral (ahorro de ~50%)
- ✅ Usar RDS Reserved Instances (ahorro de ~30-40%)

---

## 🧪 Entorno de Staging

### Configuración

- **Instancias EC2**: 2 t3.small
- **RDS**: db.t3.small, Multi-AZ
- **Auto Scaling**: 2-4 instancias
- **NAT Gateway**: 2 (Multi-AZ)
- **EFS**: Almacenamiento estándar con backups
- **Backups**: Retención de 7 días

### Desglose de Costes

| Servicio | Especificación | Coste Mensual |
|----------|----------------|---------------|
| **EC2 Instances** | 2x t3.small (730 horas/mes) | $30.37 |
| **EBS Volumes** | 16 GB gp3 (2 instancias) | $1.60 |
| **Application Load Balancer** | 1 ALB + LCU | $16.20 + $8.00 |
| **NAT Gateway** | 2x NAT Gateway (Multi-AZ) | $65.70 |
| **NAT Gateway Data** | 20 GB procesados | $1.80 |
| **RDS MySQL** | db.t3.small, Multi-AZ, 20 GB | $30.66 |
| **RDS Storage** | 20 GB gp3 | $2.30 |
| **RDS Backup** | 40 GB (7 días retención) | $4.00 |
| **EFS** | 10 GB almacenamiento estándar | $3.00 |
| **EFS Backup** | 10 GB backup | $1.00 |
| **Data Transfer** | 20 GB salida a Internet | $1.80 |

**Total Estimado**: **$120 - $150/mes**

### Optimizaciones Posibles

- ✅ Usar RDS Reserved Instances (ahorro de ~$10/mes)
- ✅ Implementar lifecycle policies en EFS (ahorro de ~20%)
- ✅ Apagar entorno fuera de horario de pruebas (ahorro de ~40%)

---

## 🚀 Entorno de Producción

### Configuración

- **Instancias EC2**: 2-6 t3.medium (promedio 2)
- **RDS**: db.t3.medium, Multi-AZ
- **Auto Scaling**: 2-6 instancias
- **NAT Gateway**: 2 (Multi-AZ)
- **EFS**: Almacenamiento estándar con backups
- **Backups**: Retención de 30 días
- **Monitoreo detallado**: Habilitado

### Desglose de Costes

| Servicio | Especificación | Coste Mensual |
|----------|----------------|---------------|
| **EC2 Instances** | 2x t3.medium (730 horas/mes) | $60.74 |
| **EBS Volumes** | 16 GB gp3 (2 instancias) | $1.60 |
| **Application Load Balancer** | 1 ALB + LCU (mayor tráfico) | $16.20 + $15.00 |
| **NAT Gateway** | 2x NAT Gateway (Multi-AZ) | $65.70 |
| **NAT Gateway Data** | 50 GB procesados | $4.50 |
| **RDS MySQL** | db.t3.medium, Multi-AZ, 50 GB | $61.32 |
| **RDS Storage** | 50 GB gp3 | $5.75 |
| **RDS Backup** | 150 GB (30 días retención) | $15.00 |
| **EFS** | 20 GB almacenamiento estándar | $6.00 |
| **EFS Backup** | 20 GB backup | $2.00 |
| **CloudWatch** | Métricas detalladas + logs | $10.00 |
| **Data Transfer** | 50 GB salida a Internet | $4.50 |

**Total Estimado**: **$250 - $350/mes**

### Costes Adicionales en Picos de Tráfico

Si el Auto Scaling escala a 6 instancias t3.medium:

| Componente | Coste Adicional |
|------------|-----------------|
| 4 instancias EC2 adicionales | +$121.48/mes |
| EBS adicional | +$3.20/mes |
| Data transfer adicional | +$5.00/mes |

**Total con escalado máximo**: **~$500/mes**

### Optimizaciones Posibles

- ✅ **RDS Reserved Instances** (1 año): Ahorro de ~30% ($18/mes)
- ✅ **EC2 Savings Plans** (1 año): Ahorro de ~20% ($12/mes)
- ✅ **EFS Lifecycle Policies**: Mover archivos antiguos a IA (ahorro de ~50% en storage)
- ✅ **CloudFront CDN**: Reducir data transfer desde ALB (ahorro de ~30%)
- ✅ **S3 para assets estáticos**: Mover imágenes/CSS/JS a S3 (ahorro de ~$10/mes)

**Ahorro potencial total**: **~$40-60/mes** (15-20% de reducción)

---

## 📈 Comparativa por Entorno

### Coste por Componente

| Componente | Dev | Staging | Prod |
|------------|-----|---------|------|
| **Compute (EC2)** | $8 | $32 | $62 |
| **Load Balancer** | $21 | $24 | $31 |
| **NAT Gateway** | $67 | $67 | $70 |
| **Database (RDS)** | $20 | $37 | $82 |
| **Storage (EFS)** | $2 | $4 | $8 |
| **Backups** | $2 | $5 | $17 |
| **Monitoring** | - | - | $10 |
| **Data Transfer** | $1 | $2 | $5 |
| **TOTAL** | **$121** | **$171** | **$285** |

### Distribución de Costes (Producción)

```
NAT Gateway:     24.5% ████████████
RDS:             28.8% ██████████████
EC2:             21.8% ███████████
ALB:             10.9% █████
Backups:          6.0% ███
EFS:              2.8% █
Monitoring:       3.5% ██
Data Transfer:    1.7% █
```

**Observación**: NAT Gateway y RDS representan más del 50% del coste total.

---

## 💡 Estrategias de Optimización de Costes

### 1. Optimización de NAT Gateway

**Problema**: NAT Gateway es uno de los componentes más costosos (~$66/mes por gateway).

**Soluciones**:
- ✅ **Desarrollo**: Usar un solo NAT Gateway (ahorro de $33/mes)
- ✅ **Producción**: Considerar NAT Instances en lugar de NAT Gateway (ahorro de ~60%)
- ✅ **VPC Endpoints**: Usar VPC endpoints para servicios AWS (S3, DynamoDB) para evitar NAT

**Ahorro potencial**: $30-40/mes por entorno

### 2. Optimización de RDS

**Problema**: RDS Multi-AZ duplica el coste de la instancia.

**Soluciones**:
- ✅ **Reserved Instances**: Compromiso de 1 año (ahorro de 30-40%)
- ✅ **Aurora Serverless**: Para cargas de trabajo variables (pago por uso)
- ✅ **Snapshots automáticos**: Ajustar retención según necesidad real

**Ahorro potencial**: $15-25/mes en producción

### 3. Optimización de EC2

**Soluciones**:
- ✅ **Savings Plans**: Compromiso de 1-3 años (ahorro de 20-40%)
- ✅ **Spot Instances**: Para entornos no críticos (ahorro de hasta 90%)
- ✅ **Right-sizing**: Monitorear uso real y ajustar tamaño de instancias

**Ahorro potencial**: $10-20/mes por entorno

### 4. Optimización de Almacenamiento

**Soluciones**:
- ✅ **EFS Lifecycle Policies**: Mover archivos a Infrequent Access después de 30 días
- ✅ **S3 para assets**: Mover imágenes, CSS, JS a S3 + CloudFront
- ✅ **Compresión**: Habilitar compresión en Apache/Nginx

**Ahorro potencial**: $5-10/mes

### 5. Optimización de Data Transfer

**Soluciones**:
- ✅ **CloudFront CDN**: Cachear contenido estático
- ✅ **Compresión**: Gzip/Brotli para reducir tamaño de transferencias
- ✅ **Optimización de imágenes**: WebP, lazy loading

**Ahorro potencial**: $5-15/mes

---

## 🎯 Recomendaciones por Caso de Uso

### Sitio de Bajo Tráfico (<10,000 visitas/mes)

**Configuración recomendada**:
- 1 t3.micro EC2
- RDS db.t3.micro single-AZ
- 1 NAT Gateway
- Sin Auto Scaling

**Coste estimado**: **$40-50/mes**

### Sitio de Tráfico Medio (10,000-100,000 visitas/mes)

**Configuración recomendada**:
- 2 t3.small EC2
- RDS db.t3.small Multi-AZ
- 2 NAT Gateways
- Auto Scaling 2-4 instancias

**Coste estimado**: **$120-150/mes**

### Sitio de Alto Tráfico (>100,000 visitas/mes)

**Configuración recomendada**:
- 2-6 t3.medium EC2
- RDS db.t3.medium Multi-AZ
- 2 NAT Gateways
- CloudFront CDN
- Auto Scaling 2-6 instancias

**Coste estimado**: **$250-350/mes** (sin CDN)  
**Con optimizaciones**: **$200-280/mes**

---

## 📊 Calculadora de Costes

Para una estimación personalizada, utiliza la [AWS Pricing Calculator](https://calculator.aws/):

1. Selecciona la región (us-east-1)
2. Añade los servicios:
   - EC2 (t3.micro/small/medium)
   - RDS MySQL (t3.micro/small/medium)
   - Application Load Balancer
   - NAT Gateway
   - EFS
   - Data Transfer
3. Ajusta las cantidades según tu caso de uso

---

## 🔍 Monitoreo de Costes

### AWS Cost Explorer

Configura alertas de presupuesto en AWS:

```bash
# Crear alerta de presupuesto
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

### Tags para Cost Allocation

Todos los recursos incluyen tags para seguimiento de costes:

```hcl
tags = {
  Project     = "wordpress-ha"
  Environment = "prod"
  ManagedBy   = "Terraform"
  CostCenter  = "Production"
}
```

### Recomendaciones de Monitoreo

1. ✅ Configurar alertas de presupuesto en AWS Budgets
2. ✅ Revisar AWS Cost Explorer mensualmente
3. ✅ Usar AWS Trusted Advisor para recomendaciones
4. ✅ Implementar AWS Cost Anomaly Detection

---

## 📝 Notas Importantes

1. **Precios variables**: Los precios de AWS pueden cambiar. Verifica los precios actuales en [aws.amazon.com/pricing](https://aws.amazon.com/pricing/).

2. **Costes ocultos**: Esta estimación no incluye:
   - Transferencia de datos entre regiones
   - Snapshots manuales adicionales
   - CloudWatch Logs (más allá de lo incluido)
   - Route53 (si se usa dominio personalizado)
   - Certificados SSL (AWS Certificate Manager es gratuito)

3. **Variabilidad**: Los costes reales dependen de:
   - Tráfico del sitio
   - Tamaño de la base de datos
   - Cantidad de archivos en EFS
   - Frecuencia de escalado

4. **Optimización continua**: Revisa y optimiza costes mensualmente para mantener eficiencia.

---

## 🤝 Soporte

Para preguntas sobre costes o optimización, consulta:
- [AWS Cost Optimization](https://aws.amazon.com/pricing/cost-optimization/)
- [AWS Well-Architected Framework - Cost Optimization](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)

---

**Última actualización**: Abril 2026  
**Región de referencia**: us-east-1 (N. Virginia)
