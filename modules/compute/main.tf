# ============================================================
# Compute - Capa 2 App: EC2 (t4g.small) + Docker en subredes
# PRIVADAS, detras del ALB, con Auto Scaling Group Multi-AZ
# (min 2 / max 4, segun tabla 2.3 del enunciado EP1).
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

resource "aws_launch_template" "app" {
  name          = "${var.project_name}-lt"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.al2023_arm.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    security_groups             = [var.app_sg_id]
    associate_public_ip_address = false # Capa privada: sale a Internet solo via NAT Gateway
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/../../scripts/user-data-app.sh.tpl", {
    aws_region              = var.aws_region
    account_id              = var.account_id
    db_host                 = var.db_host
    db_user                 = var.db_user
    db_password             = var.db_password
    db_name                 = var.db_name
    frontend_image          = "${var.ecr_repo_urls["frontend"]}:latest"
    get_products_image      = "${var.ecr_repo_urls["get-products"]}:latest"
    create_product_image    = "${var.ecr_repo_urls["create-product"]}:latest"
    update_product_image    = "${var.ecr_repo_urls["update-product"]}:latest"
    delete_product_image    = "${var.ecr_repo_urls["delete-product"]}:latest"
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-lt" })
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_app_subnets
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}
