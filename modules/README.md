# Módulos Personalizados de Terraform

## Propósito del Directorio de Módulos

El directorio `modules/` está diseñado para almacenar módulos de Terraform reutilizables y personalizados que encapsulan componentes de infraestructura comunes. Los módulos permiten:

- **Reutilización de código**: Evitar duplicación de configuraciones similares
- **Abstracción**: Ocultar complejidad detrás de interfaces simples
- **Estandarización**: Mantener configuraciones consistentes en todos los entornos
- **Mantenibilidad**: Actualizar componentes en un solo lugar
- **Composición**: Construir infraestructura compleja a partir de bloques simples

## Estructura de un Módulo

Un módulo de Terraform típico sigue esta estructura:

```
modules/
└── nombre-del-modulo/
    ├── main.tf          # Recursos principales del módulo
    ├── variables.tf     # Variables de entrada del módulo
    ├── outputs.tf       # Valores de salida del módulo
    ├── versions.tf      # Restricciones de versión (opcional)
    └── README.md        # Documentación del módulo
```

### Archivos Principales

#### main.tf
Contiene los recursos de infraestructura que el módulo crea. Ejemplo:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.environment}-${var.bucket_suffix}"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
```

#### variables.tf
Define las variables de entrada que el módulo acepta:

```hcl
variable "project_name" {
  description = "Nombre del proyecto para nombrado de recursos"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
}

variable "bucket_suffix" {
  description = "Sufijo para el nombre del bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Habilitar versionado del bucket S3"
  type        = bool
  default     = true
}
```

#### outputs.tf
Expone valores que otros módulos o la configuración raíz pueden usar:

```hcl
output "bucket_id" {
  description = "ID del bucket S3 creado"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 creado"
  value       = aws_s3_bucket.this.arn
}
```

## Creación de un Nuevo Módulo

### Paso 1: Crear la Estructura del Directorio

```bash
mkdir -p modules/mi-modulo
cd modules/mi-modulo
touch main.tf variables.tf outputs.tf README.md
```

### Paso 2: Definir Variables de Entrada

En `variables.tf`, define las variables que tu módulo necesita:

```hcl
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser dev, staging o prod."
  }
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
```

### Paso 3: Implementar Recursos

En `main.tf`, crea los recursos de AWS:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}
```

### Paso 4: Definir Outputs

En `outputs.tf`, expone los valores importantes:

```hcl
output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}
```

### Paso 5: Documentar el Módulo

En `README.md`, documenta el propósito, uso y ejemplos del módulo.

## Uso de Módulos

### Llamar un Módulo desde main.tf

Para usar un módulo personalizado en tu configuración principal:

```hcl
module "s3_bucket" {
  source = "./modules/s3-bucket"

  project_name       = var.project_name
  environment        = var.environment
  bucket_suffix      = "data"
  enable_versioning  = true

  tags = {
    Component = "Storage"
    Owner     = "DevOps Team"
  }
}
```

### Acceder a Outputs del Módulo

Los outputs del módulo están disponibles usando la sintaxis `module.<nombre>.<output>`:

```hcl
resource "aws_iam_policy" "bucket_access" {
  name        = "bucket-access-policy"
  description = "Política para acceder al bucket S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${module.s3_bucket.bucket_arn}/*"
      }
    ]
  })
}
```

### Pasar Variables entre Módulos

Los módulos pueden usar outputs de otros módulos:

```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}

module "ec2_instance" {
  source = "./modules/ec2"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id  # Usar output del módulo VPC
  subnet_id    = module.vpc.public_subnet_ids[0]
}
```

## Ejemplos de Módulos Comunes

### Ejemplo 1: Módulo de Bucket S3

**Ubicación**: `modules/s3-bucket/`

**Propósito**: Crear un bucket S3 con configuración estándar de seguridad

**Uso**:
```hcl
module "app_data_bucket" {
  source = "./modules/s3-bucket"

  project_name      = var.project_name
  environment       = var.environment
  bucket_suffix     = "app-data"
  enable_versioning = true
  enable_encryption = true

  tags = {
    DataClassification = "Internal"
  }
}
```

### Ejemplo 2: Módulo de VPC

**Ubicación**: `modules/vpc/`

**Propósito**: Crear una VPC con subnets públicas y privadas

**Uso**:
```hcl
module "network" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
}
```

### Ejemplo 3: Módulo de Instancia EC2

**Ubicación**: `modules/ec2-instance/`

**Propósito**: Crear una instancia EC2 con configuración estándar

**Uso**:
```hcl
module "web_server" {
  source = "./modules/ec2-instance"

  project_name    = var.project_name
  environment     = var.environment
  instance_name   = "web-server"
  instance_type   = "t3.micro"
  ami_id          = "ami-0c55b159cbfafe1f0"
  subnet_id       = module.network.public_subnet_ids[0]
  security_groups = [module.network.web_security_group_id]

  user_data = file("${path.module}/scripts/web-server-init.sh")
}
```

### Ejemplo 4: Módulo de Base de Datos RDS

**Ubicación**: `modules/rds/`

**Propósito**: Crear una instancia RDS con configuración de alta disponibilidad

**Uso**:
```hcl
module "database" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  db_name               = "appdb"
  engine                = "postgres"
  engine_version        = "15.3"
  instance_class        = var.environment == "prod" ? "db.t3.medium" : "db.t3.micro"
  allocated_storage     = 20
  multi_az              = var.environment == "prod" ? true : false
  subnet_ids            = module.network.private_subnet_ids
  vpc_security_group_ids = [module.network.db_security_group_id]
}
```

## Mejores Prácticas

### 1. Nomenclatura Consistente

Use nombres descriptivos y consistentes para módulos y recursos:

```hcl
# Bueno
module "application_load_balancer" {
  source = "./modules/alb"
  ...
}

# Evitar
module "mod1" {
  source = "./modules/alb"
  ...
}
```

### 2. Variables con Valores por Defecto

Proporcione valores por defecto sensatos para variables opcionales:

```hcl
variable "enable_monitoring" {
  description = "Habilitar monitoreo detallado"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Días de retención de backups"
  type        = number
  default     = 7
}
```

### 3. Validación de Variables

Use bloques de validación para asegurar valores correctos:

```hcl
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string

  validation {
    condition     = can(regex("^t[23]\\.(nano|micro|small|medium|large)$", var.instance_type))
    error_message = "El tipo de instancia debe ser de la familia t2 o t3."
  }
}
```

### 4. Documentación Clara

Incluya descripciones detalladas en todas las variables y outputs:

```hcl
variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC. Debe ser un rango privado válido (10.0.0.0/8, 172.16.0.0/12, o 192.168.0.0/16)"
  type        = string
}
```

### 5. Tags Consistentes

Aplique tags estándar a todos los recursos:

```hcl
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      Module      = "s3-bucket"
    }
  )
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = local.common_tags
}
```

### 6. Outputs Útiles

Exponga información que otros módulos o usuarios necesitarán:

```hcl
output "bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Nombre de dominio del bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}
```

### 7. Versionado de Módulos

Para módulos compartidos entre proyectos, considere usar versionado:

```hcl
# Usando un módulo versionado desde Git
module "vpc" {
  source = "git::https://github.com/tu-org/terraform-modules.git//vpc?ref=v1.2.0"
  
  project_name = var.project_name
  environment  = var.environment
}
```

### 8. Separación de Concerns

Mantenga módulos enfocados en una responsabilidad específica:

```
✓ Bueno: modules/vpc/, modules/ec2/, modules/rds/
✗ Evitar: modules/infrastructure/ (demasiado amplio)
```

## Pruebas de Módulos

### Validación Básica

```bash
cd modules/mi-modulo
terraform init
terraform validate
```

### Prueba con Configuración de Ejemplo

Cree un directorio `examples/` dentro del módulo:

```
modules/mi-modulo/
├── main.tf
├── variables.tf
├── outputs.tf
└── examples/
    └── basic/
        ├── main.tf
        └── variables.tf
```

Ejemplo de `examples/basic/main.tf`:

```hcl
module "test" {
  source = "../../"

  project_name = "test-project"
  environment  = "dev"
  # ... otras variables
}

output "test_output" {
  value = module.test
}
```

Ejecute la prueba:

```bash
cd modules/mi-modulo/examples/basic
terraform init
terraform plan
```

## Recursos Adicionales

- [Documentación oficial de Módulos de Terraform](https://developer.hashicorp.com/terraform/language/modules)
- [Registro de Módulos de Terraform](https://registry.terraform.io/)
- [Mejores prácticas para módulos](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Guía de estilo de Terraform](https://developer.hashicorp.com/terraform/language/syntax/style)

## Soporte

Para preguntas o problemas relacionados con los módulos personalizados, consulte la documentación principal del proyecto o abra un issue en el repositorio.
