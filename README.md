# Infraestructura Jenkins y Vault

Este repositorio prepara la infraestructura AWS para alojar Jenkins y Vault: clúster EKS privado, grupos de nodos, roles y complementos de Kubernetes. Reutiliza las subredes de `infra-red-compartida`. La instalación y configuración de las herramientas se realiza con manifiestos propios, sin Helm, desde [despliegue-jenkins-vault](../despliegue-jenkins-vault/).

## Organización

- **`modules/iam_roles/`**: roles del clúster y de los nodos, con sus políticas AWS.
- **`modules/cluster/`**: clúster EKS y acceso del administrador.
- **`modules/red_pods/`**: red de los pods, VPC CNI y Pod Identity Agent.
- **`modules/nodos/`**: plantillas y grupos de nodos separados para Jenkins y Vault.
- **`modules/almacenamiento/`**: identidad y add-on EBS CSI para gestionar volúmenes.
- **`.github/workflows/`**: validación, plan, aplicación manual y consultas; **`scripts/`** comprueba la aprobación del plan.

En la raíz, **`main.tf`** conecta los cinco módulos y **`data.tf`** consulta la red existente. **`moved.tf`** conserva referencias al reorganizar recursos. **`backend.tf`** guarda el estado en el bucket del bootstrap bajo `jenkins-vault/terraform.tfstate`, con cifrado y bloqueo.

## Estado comprobado — 10 de octubre de 2026

**Despliegue parcial:** el control plane EKS está activo con Kubernetes 1.36 y API privada. Los grupos `jenkins` y `vault` están en `CREATE_FAILED`; AWS informa un fallo de lanzamiento EC2 por cuota Fleet. CNI y Pod Identity Agent figuran activos; EBS CSI no aparece instalado. No se acredita Jenkins/Vault funcionando en AWS. La consola tampoco permite consultar objetos Kubernetes con la identidad actual.

El código prevé un nodo `t3.large` para Jenkins y uno `t3.medium` para Vault, con discos gp3 cifrados de 40 y 20 GiB. EKS, EC2 y volúmenes generan costos mientras existan. La reanudación permanece pendiente de resolver el bloqueo AWS y revisar el plan; debe conservarse el estado existente.

## Workflows de GitHub Actions

El código local declara **4 workflows, 5 jobs y 29 pasos**; no define stages. La separación entre plan y apply manual todavía está pendiente de publicación: las capturas de Actions corresponden al workflow anterior.

- **`terraform.yml`**: push a `main`, pull request hacia `main` o ejecución manual; `checks` (6 pasos) → `plan` (9). El plan espera checks correctos, exige `AWS_DEPLOY_ENABLED=true` y `main`, y se omite en PR. Nunca aplica.
- **`terraform-apply.yml`**: solo ejecución manual; `apply` (9 pasos), con ID del run, commit y SHA-256 del plan revisado. Exige la misma variable y `main`; descarga un plan previo, sin dependencia `needs` entre workflows.
- **`catalogo.yml`**: ejecución manual de consulta; `catalogo` (3 pasos).
- **`estado.yml`**: ejecución manual de diagnóstico; `estado` (2 pasos).

Plan y apply comparten un grupo de concurrencia, sin cancelar la ejecución anterior. La variable de despliegue está ausente en GitHub: ambos quedan bloqueados. Los artefactos son privados y pueden contener datos sensibles.

| Job `checks`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Comprobar formato | Revisa el formato de raíz y módulos sin modificar archivos. |
| 4. Inicializar sin backend | Prepara módulos y proveedores sin modificar el lockfile. |
| 5. Validar | Valida la configuración Terraform. |
| 6. Probar aprobación | Ejecuta las pruebas del control de planes aprobados. |

| Job `plan`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Autenticación OIDC | Asume el rol AWS del proyecto con credenciales temporales. |
| 4. Comprobar rol vinculado | Comprueba su lectura y distingue un rol ausente de un acceso denegado. |
| 5. Comprobar catálogo y subredes | Verifica versiones de add-ons, AMI y subredes privadas contra el estado de red. |
| 6. Inicializar y validar | Conecta con el backend S3 y valida sin modificar el lockfile. |
| 7. Planificar y comprobar alcance | Guarda plan/log y solo admite los recursos autorizados con acciones create/no-op. |
| 8. Registrar plan | Registra ID del run, commit y SHA-256 del plan. |
| 9. Guardar plan privado | Incluso ante fallo, intenta conservar plan, metadatos y log disponibles durante 1 día. |

| Job `apply`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Verificar aprobación y descargar | Comprueba origen, ejecución exitosa, commit vigente, intento, metadatos y hash del plan elegido. |
| 4. Autenticación OIDC | Asume el rol AWS del proyecto con credenciales temporales. |
| 5. Inicializar y validar | Conecta con el backend existente y valida sin modificar el lockfile. |
| 6. Comprobar main | Verifica de nuevo que main apunta al commit de la ejecución. |
| 7. Aplicar plan guardado | Aplica el archivo aprobado sin generar otro plan y registra el resultado. |
| 8. Verificar infraestructura | Comprueba por API AWS clúster privado, grupos de nodos y add-ons activos; no valida pods. |
| 9. Guardar diagnóstico | Incluso ante fallo, intenta conservar apply.log y errored.tfstate disponibles durante 1 día. |

| Job `catalogo`: paso | Función |
|---|---|
| 1. Autenticación OIDC | Obtiene credenciales temporales AWS. |
| 2. Consultar compatibilidad | Consulta versiones compatibles de add-ons y AMI AL2023 para Kubernetes 1.36. |
| 3. Guardar catálogo | Conserva catalogo.json como artefacto durante 1 día. |

| Job `estado`: paso | Función |
|---|---|
| 1. Autenticación OIDC | Obtiene credenciales temporales AWS. |
| 2. Consultar estado y salud | Consulta clúster, grupos Jenkins/Vault y EBS CSI sin modificar recursos; éxito del job no implica infraestructura sana. |

## Evidencias

Capturas reales en [imágenes/](imágenes/); muestran el resultado parcial, no un despliegue completo exitoso.

| Captura | Qué muestra |
|---|---|
| [01 — Plan y apply](imágenes/01-github-plan-verificado-apply-fallido.jpg) | Plan de 4 creaciones pendientes y ejecución 38027872859 fallida. |
| [02 — Paso apply](imágenes/02-github-apply-exit-1-verificacion-omitida.jpg) | Exit code 1 y verificación posterior omitida. |
| [03 — Control plane](imágenes/03-aws-control-plane-activo-kubernetes-1-36.jpg) | Clúster activo con Kubernetes 1.36. |
| [04 — Checks](imágenes/04-github-checks-correctos-despliegue-omitido.jpg) | Ejecución 38032430334 correcta con despliegue omitido. |
| [05 — Grupos de nodos](imágenes/05-aws-grupos-jenkins-vault-create-failed.jpg) | Jenkins y Vault en Create failed. |
| [06 — Causa del fallo](imágenes/06-aws-jenkins-fallo-cuota-fleet.jpg) | Error de lanzamiento de EC2 por cuota Fleet en Jenkins. |
| [07 — Add-ons](imágenes/07-aws-dos-addons-activos-ebs-ausente.jpg) | CNI y Pod Identity Agent activos; solo dos add-ons instalados. |
| [08 — Red](imágenes/08-aws-api-privada-red-compartida.jpg) | API privada y subredes de la red compartida. |
