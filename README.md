# Terraform AWS Multi-Environment Boilerplate

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9.0-623CE4?logo=terraform&logoColor=white)
![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D5.0.0-FF9900?logo=amazon-aws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Plantilla profesional lista para producción**  
Infraestructura como código (IaC) para AWS con soporte multi-entorno, gestión de estado remoto, CI/CD automatizado y mejores prácticas de seguridad.

---

## 📋 Descripción del Proyecto

Este boilerplate proporciona una base sólida y profesional para proyectos de infraestructura en AWS utilizando Terraform. Diseñado para equipos DevOps y consultores freelance, ofrece una estructura completa y escalable que facilita la gestión de múltiples entornos (desarrollo, staging, producción) desde un único repositorio.

### ¿Por qué usar este boilerplate?

- **Ahorra tiempo**: Estructura completa lista para usar, sin necesidad de configurar desde cero
- **Mejores prácticas**: Implementa patrones probados de infraestructura como código
- **Seguridad integrada**: Cifrado de estado, gestión de credenciales y etiquetado automático
- **Colaboración eficiente**: Estado remoto con bloqueo para trabajo en equipo
- **Automatización completa**: Pipeline CI/CD con GitHub Actions para validación y despliegue
- **Escalable**: Arquitectura modular que crece con tu proyecto

---

## 🏗️ Arquitectura

![Diagrama de arquitectura](docs/architecture.png)

El proyecto utiliza **Terraform Workspaces** para separar entornos, **S3 + DynamoDB** para gestión de estado remoto con bloqueo, y **GitHub Actions** para automatización de despliegues.

---

## ✨ Características Principales

### 🌍 Multi-Entorno
- Soporte para dev, staging y prod desde un único código base
- Configuración específica por entorno mediante archivos `.tfvars`
- Separación de estado mediante Terraform Workspaces

### 🔒 Seguridad y Cumplimiento
- Cifrado de archivos de estado en S3
- Gestión segura de credenciales (sin secretos en código)
- Etiquetado automático de recursos (Environment, ManagedBy, Project)
- Principio de mínimo privilegio en permisos IAM

### 🤖 CI/CD Automatizado
- Validación automática en Pull Requests
- Plan de Terraform visible antes de aplicar cambios
- Despliegue automático al fusionar en rama principal
- Soporte para múltiples entornos en pipeline

### 📦 Arquitectura Modular
- Directorio `modules/` para componentes reutilizables
- Ejemplo funcional incluido
- Fácil extensión con nuevos módulos

### 🔄 Gestión de Estado Remoto
- Almacenamiento en S3 con versionado
- Bloqueo de estado con DynamoDB
- Prevención de modificaciones concurrentes
- Rutas de estado específicas por workspace

---

## 📚 Prerequisitos

Antes de comenzar, asegúrate de tener instalado y configurado lo siguiente:

### Software Requerido

| Herramienta | Versión Mínima | Propósito |
|-------------|----------------|-----------|
| **Terraform** | >= 1.9.0 | Motor de infraestructura como código |
| **AWS CLI** | >= 2.0 | Interacción con servicios AWS |
| **Git** | >= 2.0 | Control de versiones |

### Instalación de Terraform

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux (Ubuntu/Debian):**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows (Chocolatey):**
```powershell
choco install terraform
```

### Instalación de AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Descarga el instalador MSI desde [aws.amazon.com/cli](https://aws.amazon.com/cli/)

### Credenciales AWS

Necesitas credenciales de AWS con permisos suficientes para crear recursos. Configúralas mediante:

```bash
aws configure
```

O establece las variables de entorno:
```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Recursos AWS Previos

Antes de inicializar Terraform, debes crear manualmente:

1. **Bucket S3** para almacenar el estado de Terraform
2. **Tabla DynamoDB** para bloqueo de estado (con clave primaria `LockID` de tipo String)

Estos recursos se crean una sola vez y se reutilizan para todos los entornos.

---

## 🚀 Inicio Rápido

### 1. Crear Repositorio en GitHub

Primero, crea un nuevo repositorio en GitHub para tu proyecto:

**Opción A: Desde la interfaz web de GitHub**

1. Ve a [github.com/new](https://github.com/new)
2. Introduce el nombre del repositorio (ej: `terraform-aws-multi-env-boilerplate`)
3. Añade una descripción opcional
4. Selecciona visibilidad (público o privado)
5. **No** inicialices con README, .gitignore o licencia (ya están incluidos)
6. Haz clic en "Create repository"

**Opción B: Usando GitHub CLI**

```bash
gh repo create terraform-aws-multi-env-boilerplate --public --description "Terraform AWS Multi-Environment Boilerplate"
```

### 2. Inicializar Backend de Terraform

Antes de usar Terraform, necesitas crear los recursos AWS para el backend remoto.

#### Crear Bucket S3 para Estado

```bash
# Define el nombre de tu bucket (debe ser único globalmente)
BUCKET_NAME="tu-empresa-terraform-state"
REGION="us-east-1"

# Crear el bucket S3
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

# Habilitar versionado (recomendado para recuperación)
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Habilitar cifrado por defecto
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Bloquear acceso público (seguridad)
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

#### Crear Tabla DynamoDB para Bloqueo

```bash
# Define el nombre de tu tabla
TABLE_NAME="terraform-state-lock"

# Crear la tabla DynamoDB
aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

# Verificar que la tabla está activa
aws dynamodb describe-table \
  --table-name $TABLE_NAME \
  --region $REGION \
  --query 'Table.TableStatus'
```

**Nota**: Estos comandos crean los recursos necesarios. Guarda los nombres del bucket y la tabla para el siguiente paso.

### 3. Clonar o Inicializar el Repositorio

**Si clonaste desde GitHub:**

```bash
git clone https://github.com/tu-usuario/terraform-aws-multi-env-boilerplate.git
cd terraform-aws-multi-env-boilerplate
```

**Si empiezas desde cero:**

```bash
# Crear directorio del proyecto
mkdir terraform-aws-multi-env-boilerplate
cd terraform-aws-multi-env-boilerplate

# Inicializar Git
git init

# Añadir el remoto de GitHub
git remote add origin https://github.com/tu-usuario/terraform-aws-multi-env-boilerplate.git

# Crear estructura inicial (si usas este boilerplate como plantilla)
# ... copiar archivos del boilerplate ...

# Primer commit
git add .
git commit -m "Initial commit: Terraform AWS multi-environment boilerplate"
git branch -M main
git push -u origin main
```

### 4. Configurar Backend

Edita `backend.tf` con los nombres de tu bucket S3 y tabla DynamoDB creados en el paso 2:

```hcl
terraform {
  backend "s3" {
    bucket         = "tu-empresa-terraform-state"  # Nombre del bucket S3 creado
    key            = "terraform/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"  # Nombre de la tabla DynamoDB creada
    encrypt        = true
  }
}
```

### 5. Configurar Variables

Copia el archivo de ejemplo y personalízalo:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

```hcl
project_name = "mi-proyecto"
aws_region   = "us-east-1"
```

### 6. Inicializar Terraform

```bash
terraform init
```

Este comando:
- Descarga los providers necesarios (AWS)
- Configura el backend remoto en S3
- Prepara el directorio de trabajo

### 7. Crear y Seleccionar Workspace

Los workspaces permiten gestionar múltiples entornos con el mismo código:

```bash
# Crear workspace para desarrollo
terraform workspace new dev

# Crear workspace para staging
terraform workspace new staging

# Crear workspace para producción
terraform workspace new prod

# Listar workspaces disponibles
terraform workspace list

# Seleccionar un workspace específico
terraform workspace select dev
```

**Nota**: El workspace `default` se crea automáticamente pero no se recomienda usarlo para entornos.

### 8. Planificar Cambios

```bash
terraform plan -var-file=environments/dev.tfvars
```

### 9. Aplicar Infraestructura

```bash
terraform apply -var-file=environments/dev.tfvars
```

**Importante**: Revisa siempre el plan antes de confirmar con `yes`.

---

## 📖 Uso por Entorno

### Entorno de Desarrollo (dev)

El entorno de desarrollo es ideal para pruebas rápidas y experimentación:

```bash
# Seleccionar workspace de desarrollo
terraform workspace select dev

# Ver el plan de cambios
terraform plan -var-file=environments/dev.tfvars

# Aplicar cambios
terraform apply -var-file=environments/dev.tfvars

# Ver recursos creados
terraform state list

# Destruir recursos (si es necesario)
terraform destroy -var-file=environments/dev.tfvars
```

### Entorno de Staging

Staging replica producción para pruebas finales antes del despliegue:

```bash
# Seleccionar workspace de staging
terraform workspace select staging

# Ver el plan de cambios
terraform plan -var-file=environments/staging.tfvars

# Aplicar cambios
terraform apply -var-file=environments/staging.tfvars

# Verificar estado
terraform show
```

### Entorno de Producción (prod)

Producción requiere máxima precaución y revisión:

```bash
# Seleccionar workspace de producción
terraform workspace select prod

# Ver el plan de cambios (REVISAR CUIDADOSAMENTE)
terraform plan -var-file=environments/prod.tfvars

# Aplicar cambios (requiere confirmación explícita)
terraform apply -var-file=environments/prod.tfvars

# Para aplicar sin confirmación (solo en CI/CD)
terraform apply -var-file=environments/prod.tfvars -auto-approve
```

**Mejores prácticas para producción:**
- Siempre revisa el plan completo antes de aplicar
- Considera usar `terraform plan -out=plan.tfplan` para guardar el plan
- Aplica el plan guardado con `terraform apply plan.tfplan`
- Realiza cambios en horarios de bajo tráfico
- Ten un plan de rollback preparado

### Verificar Workspace Actual

```bash
# Ver workspace activo
terraform workspace show

# Listar todos los workspaces
terraform workspace list
```

---

## 🤖 Configuración de CI/CD con GitHub Actions

El proyecto incluye un pipeline automatizado que valida y despliega infraestructura automáticamente.

### Configurar Secretos en GitHub

Para que GitHub Actions pueda interactuar con AWS, necesitas configurar secretos:

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** → **Secrets and variables** → **Actions**
3. Haz clic en **New repository secret**
4. Añade los siguientes secretos:

| Nombre del Secreto | Valor | Descripción |
|-------------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | Tu AWS Access Key ID | Credenciales de AWS |
| `AWS_SECRET_ACCESS_KEY` | Tu AWS Secret Access Key | Credenciales de AWS |
| `AWS_REGION` | `us-east-1` (o tu región) | Región AWS por defecto |

**Recomendación de seguridad**: Crea un usuario IAM específico para CI/CD con permisos mínimos necesarios.

### Funcionamiento del Pipeline

El pipeline se ejecuta automáticamente en dos escenarios:

**En Pull Requests:**
- Valida la sintaxis de Terraform
- Ejecuta `terraform plan` para cada entorno
- Muestra los cambios propuestos como comentario en el PR

**En Merge a Main:**
- Valida la configuración
- Aplica cambios automáticamente a los tres entornos (dev, staging, prod)
- Usa los archivos `.tfvars` correspondientes

### Personalizar el Pipeline

Edita `.github/workflows/terraform.yml` para ajustar el comportamiento:

```yaml
# Cambiar entornos a desplegar
strategy:
  matrix:
    environment: [dev, staging, prod]  # Modifica según necesites

# Añadir aprobación manual para producción
# (requiere configurar environments en GitHub)
```

### Despliegue Manual desde GitHub

También puedes ejecutar el workflow manualmente:

1. Ve a **Actions** en tu repositorio
2. Selecciona el workflow "Terraform CI/CD"
3. Haz clic en **Run workflow**
4. Selecciona la rama y el entorno
5. Haz clic en **Run workflow**

---

## 🔧 Estructura del Proyecto

```
terraform-aws-multi-env-boilerplate/
├── .github/
│   └── workflows/
│       └── terraform.yml          # Pipeline CI/CD
├── docs/
│   └── architecture.png           # Diagrama de arquitectura
├── environments/
│   ├── dev.tfvars                 # Variables de desarrollo
│   ├── staging.tfvars             # Variables de staging
│   └── prod.tfvars                # Variables de producción
├── modules/
│   └── README.md                  # Guía de módulos
├── backend.tf                     # Configuración de estado remoto
├── main.tf                        # Recursos principales
├── providers.tf                   # Configuración de providers
├── variables.tf                   # Definición de variables
├── versions.tf                    # Restricciones de versión
├── terraform.tfvars.example       # Ejemplo de variables
└── README.md                      # Este archivo
```

---

## 🔐 Consideraciones de Seguridad y Mejores Prácticas

### Gestión de Credenciales

**Principio fundamental**: Las credenciales y secretos **NUNCA** deben almacenarse en el código fuente.

#### Para Desarrollo Local
```bash
# Opción 1: Variables de entorno (recomendado)
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Opción 2: AWS CLI profiles
aws configure --profile mi-proyecto
export AWS_PROFILE=mi-proyecto
```

#### Para CI/CD (GitHub Actions)
- Almacena credenciales en **GitHub Secrets** (Settings → Secrets and variables → Actions)
- Crea un usuario IAM dedicado para CI/CD con permisos específicos
- Considera usar **OIDC** (OpenID Connect) para autenticación sin credenciales de larga duración

#### Para Producción
- **Preferible**: Usa roles IAM en lugar de credenciales estáticas
- Asigna roles a instancias EC2, funciones Lambda, o servicios ECS
- Evita el uso de access keys cuando sea posible

### Archivos de Variables (.tfvars)

**⚠️ IMPORTANTE**: Los archivos `.tfvars` **NO DEBEN** contener valores sensibles.

**❌ Nunca incluyas:**
- Contraseñas de bases de datos
- Claves API o tokens
- Certificados o claves privadas
- Access keys de AWS
- Cualquier información confidencial

**✅ En su lugar, usa:**
- **AWS Secrets Manager** para secretos de aplicación
- **AWS Systems Manager Parameter Store** para configuración sensible
- **Variables de entorno** en tiempo de ejecución
- **GitHub Secrets** para valores en CI/CD

**Ejemplo de uso seguro:**
```hcl
# ❌ MAL - No hagas esto
database_password = "mi-password-super-secreto"

# ✅ BIEN - Referencia a secreto externo
database_password_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789:secret:db-password"
```

### Cifrado y Control de Acceso del Estado

#### Cifrado del Estado
El archivo de estado de Terraform puede contener información sensible. Este proyecto implementa múltiples capas de protección:

1. **Cifrado en reposo**: El bucket S3 tiene cifrado AES-256 habilitado por defecto
2. **Cifrado en tránsito**: Todas las comunicaciones con S3 usan HTTPS/TLS
3. **Versionado**: Permite recuperar versiones anteriores del estado si es necesario

#### Control de Acceso
Restringe el acceso al bucket S3 y tabla DynamoDB con políticas IAM:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::tu-bucket-terraform-state",
        "arn:aws:s3:::tu-bucket-terraform-state/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789:table/terraform-state-lock"
    }
  ]
}
```

**Recomendaciones adicionales:**
- Habilita **acceso logging** en el bucket S3 para auditoría
- Configura **MFA Delete** para proteger contra eliminación accidental
- Usa **bucket policies** para bloquear acceso público
- Implementa **replicación cross-region** para disaster recovery

### Principio de Mínimo Privilegio (Least Privilege)

El principio de mínimo privilegio establece que usuarios y servicios deben tener **solo los permisos necesarios** para realizar su función, nada más.

#### Aplicación en IAM

**Para usuarios de desarrollo:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
```

**Para CI/CD (solo lo necesario para desplegar):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

**Mejores prácticas:**
- Comienza con permisos mínimos y añade según sea necesario
- Usa **políticas gestionadas** de AWS cuando sea apropiado
- Implementa **políticas basadas en recursos** para control granular
- Revisa permisos regularmente con **IAM Access Analyzer**
- Usa **Service Control Policies (SCPs)** en AWS Organizations para límites organizacionales

#### Separación de Entornos

- **Cuentas AWS separadas**: Usa una cuenta diferente para dev, staging y prod
- **Roles específicos**: Crea roles IAM diferentes para cada entorno
- **Políticas restrictivas**: Producción debe tener las políticas más estrictas
- **Aprobaciones manuales**: Requiere aprobación humana para cambios en producción

### Mejores Prácticas Adicionales

#### Gestión de Recursos
- ✅ Usa **etiquetas (tags)** consistentes en todos los recursos
- ✅ Implementa **resource naming conventions** claras
- ✅ Habilita **AWS CloudTrail** para auditoría de cambios
- ✅ Configura **AWS Config** para monitoreo de compliance

#### Operaciones Seguras
- ✅ Revisa **siempre** el output de `terraform plan` antes de aplicar
- ✅ Usa `terraform plan -out=plan.tfplan` para guardar y revisar planes
- ✅ Implementa **aprobaciones de múltiples personas** para producción
- ✅ Mantén **backups** del estado de Terraform
- ✅ Documenta todos los cambios en infraestructura

#### Monitoreo y Alertas
- ✅ Configura **AWS CloudWatch** para monitoreo de recursos
- ✅ Implementa **alertas** para cambios no autorizados
- ✅ Usa **AWS GuardDuty** para detección de amenazas
- ✅ Revisa **AWS Security Hub** para recomendaciones de seguridad

#### Actualizaciones y Mantenimiento
- ✅ Mantén Terraform y providers actualizados
- ✅ Revisa **security advisories** de AWS y Terraform
- ✅ Implementa **automated security scanning** en CI/CD
- ✅ Realiza **auditorías de seguridad** periódicas

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Añade nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

## 👤 Autor

**Tu Nombre**  
Consultor DevOps & Cloud Engineer

- 🌐 Portfolio: [tu-portfolio.com](https://tu-portfolio.com)
- 💼 Malt: [malt.es/profile/tu-perfil](https://malt.es/profile/tu-perfil)
- 📧 Email: tu-email@ejemplo.com
- 🐙 GitHub: [@tu-usuario](https://github.com/tu-usuario)

---

## 🎯 ¿Necesitas ayuda con tu infraestructura AWS?

Si buscas un profesional experimentado para diseñar, implementar o optimizar tu infraestructura en AWS, puedo ayudarte a llevar tu proyecto al siguiente nivel.

### ¿Qué puedo hacer por ti?

- ✅ **Diseño de arquitecturas cloud** escalables, seguras y resilientes
- ✅ **Implementación de infraestructura como código** (Terraform, CloudFormation)
- ✅ **Automatización de despliegues** con CI/CD (GitHub Actions, GitLab CI, Jenkins)
- ✅ **Optimización de costes** en AWS (reducción de hasta 40% en gastos cloud)
- ✅ **Auditorías de seguridad** y cumplimiento normativo (ISO 27001, GDPR)
- ✅ **Migración a la nube** sin interrupciones en tu negocio
- ✅ **Formación y mentoría** para equipos técnicos

### ¿Por qué trabajar conmigo?

Este boilerplate es un ejemplo de mi enfoque: **soluciones profesionales, bien documentadas y listas para producción**. Trabajo con metodologías ágiles, comunicación transparente y enfoque en resultados medibles.

**💼 Disponible para proyectos freelance en [Malt](https://malt.es/profile/tu-perfil)**

**¿Hablamos de tu proyecto?** Contáctame y cuéntame qué necesitas. Primera consulta sin compromiso.

---

⭐ Si este proyecto te resulta útil, considera darle una estrella en GitHub
