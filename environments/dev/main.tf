# ============================================================
# chacon-freshbox — EP1 ARY1102 (Arquitectura Cloud)
# Caso: FreshBox SpA - Catalogo Online de Productos Organicos
# Arquitectura de 3 capas: Web (ALB) / App (EC2+Docker, ASG) / Data (EC2+MySQL)
# ============================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = "dev"
    Owner       = var.owner_name
    CostCenter  = "freshbox-organicos"
    ManagedBy   = "terraform"
  }

  # En AWS Academy no se puede crear un rol IAM nuevo (iam:CreateRole
  # bloqueado). Por eso AWS Backup reutiliza el LabRole que el propio
  # Learner Lab ya trae. Si no se especifica, se arma con el account_id.
  backup_role_arn = var.backup_iam_role_arn != "" ? var.backup_iam_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

data "aws_caller_identity" "current" {}

# ----------------------------------------------------------
# Networking: VPC de 3 capas Multi-AZ
# ----------------------------------------------------------
module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  common_tags  = local.common_tags
}

# ----------------------------------------------------------
# Security Groups segmentados por capa
# ----------------------------------------------------------
module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = var.vpc_cidr
  common_tags  = local.common_tags
}

# ----------------------------------------------------------
# ECR: 5 repositorios (frontend + 4 microservicios backend)
# ----------------------------------------------------------
module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  common_tags  = local.common_tags
}

# ----------------------------------------------------------
# Database: EC2 MySQL dedicado en la capa Data (AZ1a)
# ----------------------------------------------------------
module "database" {
  source            = "../../modules/database"
  project_name      = var.project_name
  db_subnet_id      = module.networking.private_subnets_data[0]
  db_sg_id          = module.security.db_sg_id
  instance_type     = var.instance_type
  ami_id            = var.ami_id
  key_name          = var.key_name
  db_root_password  = var.db_root_password
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
  common_tags       = local.common_tags
}

# ----------------------------------------------------------
# Load Balancer publico (capa Web)
# ----------------------------------------------------------
module "loadbalancer" {
  source         = "../../modules/loadbalancer"
  project_name   = var.project_name
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  alb_sg_id      = module.security.alb_sg_id
  common_tags    = local.common_tags
}

# ----------------------------------------------------------
# Compute: ASG de EC2 App (2-4 instancias) en subredes privadas
# ----------------------------------------------------------
module "compute" {
  source              = "../../modules/compute"
  project_name        = var.project_name
  vpc_id              = module.networking.vpc_id
  private_app_subnets = module.networking.private_subnets_app
  target_group_arn    = module.loadbalancer.target_group_arn
  app_sg_id           = module.security.app_sg_id
  instance_type       = var.instance_type
  ami_id              = var.ami_id
  key_name            = var.key_name

  aws_region    = var.aws_region
  account_id    = data.aws_caller_identity.current.account_id
  db_host       = module.database.db_private_ip
  db_user       = module.database.db_username
  db_password   = var.db_password
  db_name       = module.database.db_name
  ecr_repo_urls = module.ecr.repo_urls

  common_tags = local.common_tags
}

# ----------------------------------------------------------
# AWS Backup — respaldo diario de la EC2 MySQL
# ----------------------------------------------------------
module "backup" {
  source               = "../../modules/backup"
  project_name         = var.project_name
  db_instance_arn      = module.database.db_instance_arn
  backup_iam_role_arn  = local.backup_role_arn
  common_tags          = local.common_tags
}

# ----------------------------------------------------------
# Monitoreo CloudWatch + SNS
# ----------------------------------------------------------
module "monitoring" {
  source         = "../../modules/monitoring"
  project_name   = var.project_name
  aws_region     = var.aws_region
  asg_name       = module.compute.asg_name
  alb_arn_suffix = module.loadbalancer.alb_arn_suffix
  db_instance_id = module.database.db_instance_id
  email_sns      = var.email_sns
  common_tags    = local.common_tags
}

# ----------------------------------------------------------
# AWS Budgets — control de costos con alertas SNS
# ----------------------------------------------------------
module "budgets" {
  source             = "../../modules/budgets"
  project_name       = var.project_name
  enable_budgets     = var.enable_budgets
  monthly_budget_usd = var.monthly_budget_usd
  ec2_budget_usd     = var.ec2_budget_usd
  sns_topic_arn      = module.monitoring.sns_topic_arn
}

# ----------------------------------------------------------
# CloudTrail — auditoria y trazabilidad
# ----------------------------------------------------------
#module "cloudtrail" {
#  source       = "../../modules/cloudtrail"
#  project_name = var.project_name
#  account_id   = data.aws_caller_identity.current.account_id
#  common_tags  = local.common_tags
#}

# NOTA: el modulo "governance" (roles/politicas IAM propios) NO se incluye
# porque AWS Academy bloquea iam:CreateRole/CreatePolicy para el usuario
# del Lab. El gobierno IAM se documenta en el informe a nivel de
# LabRole/LabInstanceProfile (que ya trae sus propias politicas).
