# ============================================================
# Database - Capa 3 Data: EC2 Amazon Linux + MySQL dedicado
# (segun tabla 2.3 del enunciado EP1: "Servidor de base de
# datos dedicado", no RDS)
# ============================================================

data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "mysql" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.al2023_arm.id
  instance_type          = var.instance_type
  subnet_id              = var.db_subnet_id
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = var.key_name != "" ? var.key_name : null

  iam_instance_profile = "LabInstanceProfile"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile("${path.module}/../../scripts/user-data-db.sh.tpl", {
    db_root_password = var.db_root_password
    db_user           = var.db_username
    db_password       = var.db_password
    db_name           = var.db_name
    db_init_sql_b64   = base64encode(file("${path.module}/../../app/db/init.sql"))
  }))

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-mysql"
    Capa = "data-privada"
  })
}
