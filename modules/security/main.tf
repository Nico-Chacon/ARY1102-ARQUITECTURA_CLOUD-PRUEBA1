# ============================================================
# Security Groups segmentados por capa: ALB -> App -> Data
# Minimo privilegio: cada capa solo acepta trafico de la capa
# inmediatamente anterior (segun tabla 2.4 del enunciado EP1).
# ============================================================

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "SG del Application Load Balancer (capa publica)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS publico"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-sg-alb" })
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg-app"
  description = "SG de las EC2 App (capa privada) - solo recibe trafico del ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP desde el ALB (Nginx del contenedor frontend)"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH solo desde dentro de la VPC (troubleshooting). Se recomienda usar SSM Session Manager."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-sg-app" })
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-sg-db"
  description = "SG de la EC2 MySQL (capa Data) - solo recibe trafico de la capa App"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL solo desde EC2 App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description = "SSH solo desde dentro de la VPC (troubleshooting)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-sg-db" })
}
