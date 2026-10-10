# Infraestructura Jenkins y Vault

Clúster EKS prueba-devops-jenkins-vault en us-east-1, Kubernetes 1.36 con API exclusivamente privada. Usa dos subredes privadas de infra-red-compartida. Autenticación API; no concede administración automática al creador. El usuario IAM manuel-dev recibe AmazonEKSClusterAdminPolicy mediante access entry.

## Responsabilidades

- identidad_base: roles del clúster/nodos y políticas AWS. Outputs esperan a sus asociaciones IAM.
- cluster: EKS y acceso administrador.
- red_pods: rol CNI, asociación Pod Identity y addons VPC CNI/agente.
- nodos: plantillas y grupos Jenkins/Vault explícitos, sin bucles.
- almacenamiento: rol, asociación Pod Identity y addon EBS CSI.

main.tf conecta cinco módulos; moved.tf conserva las direcciones de raíz y module.eks, incluidas las antiguas instancias herramientas["jenkins"] y herramientas["vault"]. Hay 21 recursos finales. No hay locals/for/for_each. Backend/provider quedan en raíz; no se crean outputs públicos nuevos.

Jenkins: un t3.large en us-east-1a, disco gp3 cifrado de 40 GiB. Vault: un t3.medium en us-east-1b, disco gp3 cifrado de 20 GiB. Capacidad ON_DEMAND, min/max/desired 1 por grupo. IMDSv2 obligatorio, hop limit 1 y créditos CPU standard. No IP públicas ni SSH configurado.

## Versiones verificadas

Catálogo AWS consultado en us-east-1 por OIDC, run 38026057070: Kubernetes 1.36, Pod Identity Agent v1.3.10-eksbuild.3, VPC CNI v1.22.4-eksbuild.3, EBS CSI v1.66.0-eksbuild.1. AMI AL2023_x86_64_STANDARD release 1.36.4-20261003, imagen ami-0168ea3fb7ca2dbbe de AWS. Valores fijados en los recursos; el workflow vuelve a comprobar disponibilidad/compatibilidad antes del plan. Registro técnico en .github/catalogo-verificado.json. Terraform 1.15.9, AWS 6.68.0 fijado con lock.

EKS inicia CNI/kube-proxy/CoreDNS self-managed por defecto. El recurso vpc-cni adopta el CNI con resolve_conflicts_on_create=OVERWRITE. Pod Identity usa roles dedicados CNI/EBS, confianza limitada al ARN del clúster, namespace y service account, y session tags habilitadas. El rol de nodos incluye AmazonEKSWorkerNodePolicy y AmazonEC2ContainerRegistryPullOnly; el CNI tiene política separada.

## Orden de arranque

Roles base/políticas → clúster → asociación CNI → nodos. El output cluster_name_for_nodes espera solo la asociación, no la salud de los addons; así el agente y CNI pueden arrancar con los nodos sin espera circular. No añadir depends_on=[module.red_pods] al módulo nodos. Los addons de red se gestionan en paralelo; almacenamiento espera ambos grupos y el módulo de red completo. Los nodos privados salen a APIs AWS/ECR mediante NAT de su AZ; S3 usa endpoint gateway.

## Despliegue y estado

Backend S3 bucket tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis, key jenkins-vault/terraform.tfstate, región us-east-1, cifrado y use_lockfile=true. Consume outputs private_subnet_ids y private_subnet_ids_by_az del estado red-compartida/terraform.tfstate. No versionar estado ni credenciales.

Workflow catalogo.yml: consulta de solo lectura por workflow_dispatch. terraform.yml: push/main o workflow_dispatch realiza checks, OIDC con prueba-devops-github-actions-jenkins-vault, preflight de catálogo/subredes, init/validate/plan y apply automático del mismo plan. PR solo checks sin AWS. Acciones fijadas por SHA. La compuerta permite únicamente create/no-op de las 21 direcciones enumeradas en .github/recursos-autorizados.json; bloquea actualizaciones/eliminaciones/reemplazos y debe revisarse antes de cambios futuros.

Después del apply, verifica con API AWS clústerACTIVE/privado, ambos grupos ACTIVE con su instancia/escala/release y tres addons ACTIVE sin issues. No sustituye una comprobación de pods dentro de Kubernetes: el runner GitHub no tiene acceso a la API privada y no se abre ese acceso. Plan/diagnósticos privados se conservan 1 día; estado remoto en S3 versionado. Si falla guardar estado, recuperar errored.tfstate del artefacto privado antes de continuar.

Este repositorio despliega infraestructura y addons operativos. No instala Jenkins, Vault, Helm ni aplicaciones. EKS, dos instancias y volúmenes generan costos; los NAT pertenecen al repositorio de red. Los permisos actuales no permiten destruir infraestructura; retirada requiere revisión y autorización separadas.

## Validación

terraform fmt -check -recursive; terraform init -backend=false -lockfile=readonly; terraform validate. Validación offline: 0 errores/0 avisos. Catálogo AWS verificado; plan/apply reales se consultan en Actions.

[Versiones EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) · [Compatibilidad addons](https://docs.aws.amazon.com/eks/latest/userguide/addon-compat.html) · [Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-id-agent-setup.html) · [Plantillas de nodos](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html) · [Refactorización Terraform](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring).
