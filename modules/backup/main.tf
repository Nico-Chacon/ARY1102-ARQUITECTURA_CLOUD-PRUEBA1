# ============================================================
# AWS Backup - Respaldo de la EC2 MySQL (Capa Data)
# NOTA IMPORTANTE (AWS Academy Learner Lab):
# Academy bloquea iam:CreateRole/CreatePolicy para el usuario
# del Lab, por lo que este modulo NO crea un rol nuevo: reutiliza
# el rol "LabRole" que el propio Learner Lab ya trae preconfigurado
# con los permisos necesarios para el servicio AWS Backup.
# Si tu cuenta no tiene LabRole, reemplaza var.backup_iam_role_arn.
# ============================================================

resource "aws_backup_vault" "main" {
  name = "${var.project_name}-backup-vault"
  tags = merge(var.common_tags, { Name = "${var.project_name}-backup-vault" })
}

resource "aws_backup_plan" "daily" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup-db"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)" # 05:00 UTC todos los dias
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 7 # Retencion 7 dias
    }
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-backup-plan" })
}

resource "aws_backup_selection" "db" {
  name         = "${var.project_name}-backup-selection-db"
  iam_role_arn = var.backup_iam_role_arn
  plan_id      = aws_backup_plan.daily.id

  resources = [
    var.db_instance_arn,
  ]
}
