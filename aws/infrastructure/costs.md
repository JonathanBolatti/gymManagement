# 💰 Estimación de Costos AWS - Gym Management System

## 📋 Resumen Ejecutivo

Este documento detalla los costos estimados para la infraestructura AWS del sistema de gestión de gimnasio, optimizada para la capa gratuita de AWS durante el primer año.

## 🎯 Estrategia de Costos

### Free Tier (Primer Año)
La infraestructura está diseñada para aprovechar al máximo la capa gratuita de AWS, manteniendo los costos en **$0.00/mes** durante los primeros 12 meses.

### Post Free Tier (Después del Primer Año)
Estimación de costos mensuales: **$25-35 USD/mes**

## 📊 Desglose Detallado de Costos

### 1. Compute (EC2)

#### Free Tier (Primer Año)
| Servicio | Cantidad | Límite Free Tier | Costo |
|----------|----------|------------------|-------|
| EC2 t2.micro | 1 instancia | 750 horas/mes | **$0.00** |
| EBS gp2 | 8 GB | 30 GB incluidos | **$0.00** |

#### Post Free Tier
| Servicio | Cantidad | Precio por Hora | Costo Mensual |
|----------|----------|----------------|---------------|
| EC2 t2.micro | 1 instancia | $0.0116/hora | **$8.50** |
| EBS gp2 | 8 GB | $0.10/GB/mes | **$0.80** |
| **Subtotal EC2** | | | **$9.30** |

### 2. Base de Datos (RDS)

#### Free Tier (Primer Año)
| Servicio | Cantidad | Límite Free Tier | Costo |
|----------|----------|------------------|-------|
| RDS db.t3.micro | 1 instancia | 750 horas/mes | **$0.00** |
| RDS Storage | 20 GB | 20 GB incluidos | **$0.00** |
| Backup Storage | 20 GB | 20 GB incluidos | **$0.00** |

#### Post Free Tier
| Servicio | Cantidad | Precio | Costo Mensual |
|----------|----------|--------|---------------|
| RDS db.t3.micro | 1 instancia | $0.0161/hora | **$11.75** |
| RDS Storage gp2 | 20 GB | $0.115/GB/mes | **$2.30** |
| Backup Storage | 20 GB | $0.095/GB/mes | **$1.90** |
| **Subtotal RDS** | | | **$15.95** |

### 3. Almacenamiento (S3)

#### Free Tier (Primer Año)
| Servicio | Cantidad | Límite Free Tier | Costo |
|----------|----------|------------------|-------|
| S3 Standard | 5 GB | 5 GB incluidos | **$0.00** |
| PUT Requests | 2,000 | 2,000 incluidos | **$0.00** |
| GET Requests | 20,000 | 20,000 incluidos | **$0.00** |

#### Post Free Tier
| Servicio | Cantidad Estimada | Precio | Costo Mensual |
|----------|-------------------|--------|---------------|
| S3 Standard | 10 GB | $0.023/GB/mes | **$0.23** |
| PUT Requests | 5,000 | $0.0005/1000 | **$0.003** |
| GET Requests | 50,000 | $0.0004/1000 | **$0.02** |
| **Subtotal S3** | | | **$0.25** |

### 4. Monitoreo (CloudWatch)

#### Free Tier (Primer Año)
| Servicio | Cantidad | Límite Free Tier | Costo |
|----------|----------|------------------|-------|
| Métricas básicas | 10 métricas | 10 incluidas | **$0.00** |
| Alarmas | 10 alarmas | 10 incluidas | **$0.00** |
| Logs | 5 GB | 5 GB incluidos | **$0.00** |

#### Post Free Tier
| Servicio | Cantidad Estimada | Precio | Costo Mensual |
|----------|-------------------|--------|---------------|
| Métricas custom | 20 métricas | $0.30/métrica/mes | **$6.00** |
| Alarmas | 15 alarmas | $0.10/alarma/mes | **$1.50** |
| Logs ingestion | 10 GB | $0.50/GB | **$5.00** |
| Logs storage | 50 GB | $0.0276/GB/mes | **$1.38** |
| **Subtotal CloudWatch** | | | **$13.88** |

### 5. Networking

#### Free Tier y Post Free Tier
| Servicio | Cantidad | Límite Free Tier | Costo |
|----------|----------|------------------|-------|
| Data Transfer OUT | < 1 GB/mes | 1 GB incluido | **$0.00** |
| VPC, Subnets, IGW | N/A | Gratuito | **$0.00** |
| Security Groups | N/A | Gratuito | **$0.00** |

### 6. Seguridad (IAM)

#### Siempre Gratuito
| Servicio | Cantidad | Precio | Costo |
|----------|----------|--------|-------|
| IAM Users, Roles, Policies | Ilimitado | Gratuito | **$0.00** |
| Multi-Factor Auth | Ilimitado | Gratuito | **$0.00** |

## 📈 Proyección de Costos por Escenarios

### Escenario 1: Desarrollo/Testing (Free Tier)
```
┌─────────────────────────────────────────┐
│  PRIMER AÑO - FREE TIER                 │
│  Total mensual: $0.00                   │
│  Total anual: $0.00                     │
└─────────────────────────────────────────┘
```

### Escenario 2: Post Free Tier (Año 2+)
```
┌─────────────────────────────────────────┐
│  DESPUÉS DEL PRIMER AÑO                 │
│  ├── EC2 + EBS: $9.30                   │
│  ├── RDS: $15.95                        │
│  ├── S3: $0.25                          │
│  ├── CloudWatch: $13.88                 │
│  ├── Networking: $0.00                  │
│  └── IAM: $0.00                         │
│  ─────────────────────────               │
│  Total mensual: $39.38                  │
│  Total anual: $472.56                   │
└─────────────────────────────────────────┘
```

### Escenario 3: Optimizado Post Free Tier
```
┌─────────────────────────────────────────┐
│  OPTIMIZACIÓN DE COSTOS                 │
│  ├── EC2 t2.micro: $9.30                │
│  ├── RDS db.t3.micro: $15.95            │
│  ├── S3 optimizado: $0.15               │
│  ├── CloudWatch básico: $5.00           │
│  ├── Networking: $0.00                  │
│  └── IAM: $0.00                         │
│  ─────────────────────────               │
│  Total mensual: $30.40                  │
│  Total anual: $364.80                   │
└─────────────────────────────────────────┘
```

## 🔧 Estrategias de Optimización de Costos

### 1. Durante Free Tier (Año 1)
- **Monitoreo activo**: Configurar alarmas de billing
- **Uso eficiente**: Mantenerse dentro de los límites
- **Cleanup regular**: Eliminar recursos no utilizados

### 2. Post Free Tier (Año 2+)

#### Compute Optimization
- **Reserved Instances**: 30-60% descuento para cargas predecibles
- **Spot Instances**: Para tareas no críticas
- **Right-sizing**: Monitorear y ajustar tipos de instancia

#### Storage Optimization
- **S3 Lifecycle Policies**: Transición automática a clases más baratas
- **EBS Snapshots**: Backup eficiente y eliminación de antiguos
- **Data Compression**: Reducir volumen de datos

#### Monitoring Optimization
- **Log Retention**: Configurar retención apropiada (7-30 días)
- **Métricas Selectivas**: Solo métricas esenciales
- **Dashboard Consolidation**: Reducir número de dashboards

### 3. Proyecciones de Crecimiento

#### 100 Usuarios Concurrentes
| Componente | Cambio Recomendado | Costo Adicional |
|------------|-------------------|-----------------|
| EC2 | t2.small | +$17/mes |
| RDS | db.t3.small | +$25/mes |
| CloudWatch | Más métricas | +$10/mes |
| **Total** | | **+$52/mes** |

#### 500 Usuarios Concurrentes
| Componente | Cambio Recomendado | Costo Adicional |
|------------|-------------------|-----------------|
| EC2 | t2.medium + ALB | +$75/mes |
| RDS | db.t3.medium | +$80/mes |
| S3 | Más storage + CloudFront | +$15/mes |
| **Total** | | **+$170/mes** |

## 💡 Recomendaciones para Control de Costos

### 1. Alertas y Monitoreo
```bash
# Configurar alertas de billing
aws budgets create-budget \
    --account-id 123456789012 \
    --budget '{
        "BudgetName": "MonthlyBudget",
        "BudgetLimit": {"Amount": "50", "Unit": "USD"},
        "TimeUnit": "MONTHLY",
        "BudgetType": "COST"
    }'
```

### 2. Políticas de Lifecycle
- **S3**: Mover a IA después de 30 días, Glacier después de 90 días
- **CloudWatch Logs**: Retención de 30 días máximo
- **EBS Snapshots**: Automatizar eliminación de snapshots antiguos

### 3. Programación de Recursos
- **Auto Scaling**: Escalar hacia abajo durante horas no pico
- **Scheduled Actions**: Apagar instancias de desarrollo por las noches
- **Weekend Shutdown**: Instancias de testing solo en horario laboral

### 4. Análisis de Costos
- **Cost Explorer**: Análisis mensual de gastos
- **AWS Trusted Advisor**: Recomendaciones de optimización
- **Resource Tags**: Seguimiento detallado por proyecto/ambiente

## 📊 Herramientas de Control de Costos

### 1. AWS Cost Explorer
- **Análisis histórico**: Últimos 12 meses
- **Forecasting**: Proyección de gastos futuros
- **Rightsizing**: Recomendaciones de optimización

### 2. AWS Budgets
- **Budget Alerts**: Notificaciones al 80% y 100% del presupuesto
- **Cost Anomaly Detection**: Alertas de gastos inusuales
- **RI Utilization**: Monitoreo de uso de Reserved Instances

### 3. Third-Party Tools
- **CloudCheckr**: Análisis detallado de costos
- **ParkMyCloud**: Automatización de schedules
- **Spot.io**: Optimización con Spot Instances

## 🎯 ROI y Justificación

### Comparación con Alternativas

#### Hosting Tradicional
| Concepto | AWS | Hosting Tradicional |
|----------|-----|-------------------|
| Setup inicial | $0 | $500-1000 |
| Costo mensual (Año 1) | $0 | $50-100 |
| Costo mensual (Año 2+) | $30-40 | $80-150 |
| Escalabilidad | Inmediata | Limitada |
| Backup/Disaster Recovery | Incluido | Extra $20-50/mes |

#### SaaS Alternatives
| Concepto | AWS Custom | SaaS Solution |
|----------|------------|---------------|
| Costo mensual | $30-40 | $100-300 |
| Customización | Completa | Limitada |
| Ownership | Total | Ninguna |
| Data Control | Completo | Limitado |

### Break-even Analysis
- **Inversión inicial**: $0 (Free Tier)
- **Desarrollo**: Costo de tiempo de equipo
- **Break-even vs SaaS**: 3-6 meses
- **Break-even vs Hosting tradicional**: Inmediato

## 📅 Roadmap de Costos

### Mes 1-12: Free Tier
- Costo: $0/mes
- Foco: Desarrollo y testing
- Monitoreo: Uso de Free Tier

### Mes 13-24: Post Free Tier
- Costo: $30-40/mes
- Foco: Optimización y crecimiento
- Implementar: Reserved Instances

### Mes 25+: Escalamiento
- Costo: Variable según crecimiento
- Foco: Performance y disponibilidad
- Considerar: Multi-AZ, Load Balancers

## 🔍 Conclusiones

1. **Free Tier Maximization**: Infraestructura $0 durante primer año
2. **Post Free Tier Viability**: $30-40/mes es competitivo
3. **Escalabilidad**: Pay-as-you-grow model
4. **Control**: Flexibilidad total en costos y arquitectura
5. **ROI**: Positivo desde el primer año comparado con alternativas 